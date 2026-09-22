import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/subjects.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/repositories/model_repository_events.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

typedef ModelID = String;

// TODO make this immutable
class WrappedModel<T>(var T _model) {
  this {
    model = _model;
  }

  T get model => _model;
  set model(T model) {
    _model = model;
    asyncValue = AsyncData<T>(model);
  }

  AsyncValue<T> asyncValue = AsyncValue<T>.loading();

  bool isMarkedForRefresh = false;
  bool isLocalOnly = true;
  bool isDirty = false;
  bool isDeleted = false;
  DateTime? lastSaved;
  DateTime? lastFetched;
  DateTime? lastUpdated;

  void markWithError(Object error, {StackTrace? stackTrace}) {
    asyncValue = AsyncValue<T>.error(error, stackTrace ?? StackTrace.current);
  }

  void markAsLoading() {
    // Riverpod made copyWithPrevious internal in v3.0.0-dev.17 (2025-08-01).
    // To prevent circular progress indicators on every update in the designer,
    // we manually preserve the previous value here.
    asyncValue = AsyncValue<T>.data(_model);
  }

  void markAsFetched() {
    if (isDirty) {
      throw Exception(
        "Dirty model marked as fetched, potentially resulting in "
        "loss of unsaved changes.",
      );
    }
    isLocalOnly = false;
    lastFetched = DateTime.now();
  }

  void markAsSaved() {
    isDirty = false;
    isLocalOnly = false;
    lastSaved = DateTime.now();
  }
}

class ModelRepositoryException() implements Exception;

class ModelNotFoundException() implements ModelRepositoryException;

abstract class IModelRepository<T>() implements IModelActionProvider<T> {
  ModelID getKey(T model);
  WrappedModel<T>? get(ModelID modelId);
  Future<List<WrappedModel<T>>> fetchAll();
  Future<WrappedModel<T>> fetch(ModelID modelId);
  Future<WrappedModel<T>?> save(T model); // upsert
  Future<void> delete(ModelID modelId);
  Future<void> duplicateAndSave(T model);

  // Future<void> duplicateAndSaveFromRemote(ModelID modelId);
  Stream<WrappedModel<T>> watch(
    ModelID modelId, {
    bool fetchOnSubscribe = true,
  });
  Stream<List<WrappedModel<T>>> watchAll({bool fetchOnSubscribe = true});
  Stream<ModelEvent<T>> watchChanges(ModelID modelId);
  Stream<ModelEvent<T>> watchAllChanges();
  Future<WrappedModel<T>?> ensurePersisted(ModelID modelId);
  void dispose();
}

abstract class IModelRepositoryDelegate<T>() {
  Future<List<T>> fetchAll();
  Future<T> fetch(ModelID modelId);
  Future<T> save(T model);
  // todo saveAll(List<T> models);
  Future<void> delete(T model);
  // todo deleteAll(List<T> models);
  T createNewInstance();
  T createDuplicate(T model);
  void onError(Object error, StackTrace? stackTrace);
}

// TODO: revisit user-facing error handling & flow
abstract class ModelRepository<T>(
  /// Injected delegate reference
  final IModelRepositoryDelegate<T> delegate,
) extends IModelRepository<T> {
  /// Stream controller for broadcasting all models stored in the repository
  final BehaviorSubject<List<WrappedModel<T>>> _allModelsStreamController =
      BehaviorSubject();
  final BehaviorSubject<ModelEvent<T>> _allModelEventsStreamController =
      BehaviorSubject();

  /// Stream controllers for subscriptions on individual models of type [T]
  final Map<ModelID, BehaviorSubject<WrappedModel<T>>> modelStreamControllers =
      {};
  final Map<ModelID, BehaviorSubject<ModelEvent<T>>>
  modelEventsStreamControllers = {};

  /// Collection of all models of type [T]
  ///
  /// Contains both unpersisted / local-only objects of type [T] (see
  /// [_unpersistedModels]) as well as models fetched from the backend
  final Map<ModelID, WrappedModel<T>> _allModels = {};

  Map<ModelID, WrappedModel<T>> get modelCache => _allModels;

  @override
  WrappedModel<T>? get(ModelID modelId, {bool strict = false}) {
    if (modelCache.containsKey(modelId)) {
      return modelCache[modelId];
    }
    if (strict) {
      throw ModelNotFoundException();
    }
    return null;
  }

  @override
  Future<List<WrappedModel<T>>> fetchAll() async {
    List<WrappedModel<T>> wrappedModels = [];
    try {
      final models = await delegate.fetchAll();
      wrappedModels = upsertAllLocally(models);
      for (final wrappedModel in wrappedModels) {
        wrappedModel.markAsFetched();
      }
    } catch (e, stackTrace) {
      emitError(_allModelsStreamController, e, stackTrace);
      rethrow;
    }

    emitUpdate();

    return wrappedModels;
  }

  @override
  Future<WrappedModel<T>> fetch(ModelID modelId) async {
    if (modelId == Config.newModelId) {
      throw ModelNotFoundException();
    }

    final existingWrappedModel = get(modelId);
    existingWrappedModel?.markAsLoading();

    late final WrappedModel<T>? wrappedModel;
    try {
      final model = await delegate.fetch(modelId);
      wrappedModel = upsertLocally(model);
      wrappedModel.markAsFetched();
      wrappedModel.isMarkedForRefresh = false; // Clear the refresh flag
      emitModelEvent(IsFetched(modelId, model));
    } catch (e, stackTrace) {
      print("Error fetching model $modelId: $e with $stackTrace");
      // Associate error with existing object if possible, otherwise bubble up
      if (existingWrappedModel != null) {
        existingWrappedModel.markWithError(e);
        emitError(modelStreamControllers[modelId], e, stackTrace);
      } else {
        rethrow;
      }
    }
    emitUpdate();
    return wrappedModel!;
  }

  @override
  Future<WrappedModel<T>?> save(T model, {bool runOptimistically = true}) {
    final modelId = getKey(model);
    final prevModel = get(modelId)?.model;

    final saveOperation = OptimisticUpdate(
      applyOptimistic: () {
        final wrappedModel = upsertLocally(model);
        wrappedModel.markAsLoading();
      },
      apply: () async {
        emitModelEvent(IsSaving(modelId, model));
        final savedModel = await delegate.save(model);
        final wrappedModel = upsertLocally(savedModel);
        wrappedModel.markAsSaved();
        emitModelEvent(IsSaved(modelId, model));
      },
      rollback: () {
        if (prevModel == null) {
          // didn't exist previously
          modelCache.remove(modelId);
        } else {
          // undo any changes
          final wrappedModel = get(modelId);
          wrappedModel!.model = prevModel;
        }
      },
      onUpdate: emitUpdate,
      onError: (e, stackTrace) {
        get(modelId)?.markWithError(e);
        emitError(modelStreamControllers[modelId], e, stackTrace);
      },
      rethrowErrors: true,
      runOptimistically: runOptimistically,
      completeFutureOptimistically: runOptimistically,
    );

    return saveOperation.execute().then((_) => get(modelId));
  }

  @override
  Future<void> delete(ModelID modelId, {bool runOptimistically = true}) {
    final wrappedModel = get(modelId);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }
    wrappedModel.markAsLoading();

    final deleteOperation = OptimisticUpdate(
      applyOptimistic: () => wrappedModel.isDeleted = true,
      apply: () async {
        final model = wrappedModel.model;
        if (!wrappedModel.isLocalOnly) {
          await delegate.delete(model);
        }
        // Model already flagged as deleted, free it for garbage collection
        if (modelCache.containsKey(modelId)) {
          modelCache.remove(modelId);
        }
        emitModelEvent(IsDeleted(modelId, model));
      },
      rollback: () => wrappedModel.isDeleted = false,
      onUpdate: emitUpdate,
      onError: (e, stackTrace) {
        get(modelId)?.markWithError(e);
        emitError(modelStreamControllers[modelId], e, stackTrace);
      },
      rethrowErrors: true,
      runOptimistically: runOptimistically,
      // Delete callers must wait for backend completion before showing
      // success UI or reloading lists; otherwise the study can appear to
      // "delete successfully" while the request is still in flight.
      completeFutureOptimistically: false,
    );

    return deleteOperation.execute();
  }

  @override
  Future<void> duplicateAndSave(T model) {
    final duplicateModel = delegate.createDuplicate(model);
    return save(duplicateModel);
  }

  /*@override
  Future<void> duplicateAndSaveFromRemote(ModelID modelId) async {
    WrappedModel<T>? wrappedModel = get(modelId);
    wrappedModel ??= await fetch(modelId);
    final duplicateModel = delegate.createDuplicate(wrappedModel.model);
    await save(duplicateModel);
  }*/

  @override
  Stream<List<WrappedModel<T>>> watchAll({bool fetchOnSubscribe = true}) {
    // Note: we don't use Stream.fromFuture here because it automatically
    // closes the stream when the future resolves
    if (fetchOnSubscribe) {
      fetchAll();
    }
    return _allModelsStreamController;
  }

  /// Returns a stream that emits the model of type [T] identified by the
  /// given [ModelID].
  ///
  /// If [fetchOnSubscribe] is true, the individual model will be fetched
  /// from the network and upserted into the local cache.
  ///
  /// If the requested [ModelId] is not available, the stream will be created
  /// anyway, but emit a [ModelNotFoundException] error event.
  @override
  Stream<WrappedModel<T>> watch(
    ModelID modelIdParam, {
    bool fetchOnSubscribe = true,
    bool emitLastEvent = true,
  }) {
    WrappedModel<T>? wrappedModel;
    ModelID modelId = modelIdParam;

    if (modelId == Config.newModelId) {
      // Create new model to subscribe to
      final newModel = delegate.createNewInstance();
      wrappedModel = upsertLocally(newModel, emitUpdate: true);
      modelId = getKey(newModel); // subscribe to the newly created study
    } else {
      // Subscribe to existing model (may not be fetched yet)
      wrappedModel = get(modelId, strict: !fetchOnSubscribe);
      if (wrappedModel?.isMarkedForRefresh ?? false) {
        wrappedModel = null; // force refetch
        //wrappedModel!.markAsLoading();
        //_allModels.remove(modelId);
        // emitUpdate();
      }
    }

    WrappedModel<T>? selectModel(List<WrappedModel<T>> event) {
      for (final wrappedModel in event) {
        if (getKey(wrappedModel.model) == modelId) {
          if (wrappedModel.isMarkedForRefresh) {
            return null; // force refetch
          }
          return wrappedModel;
        }
      }
      return null;
    }

    final modelController = _buildModelSpecificController(
      modelId,
      _allModelsStreamController,
      modelStreamControllers,
      selectModel,
    );

    if (fetchOnSubscribe) {
      if (!(wrappedModel != null && wrappedModel.isLocalOnly) ||
          wrappedModel.isMarkedForRefresh) {
        fetch(modelId).catchError((Object e) {
          if (!modelController.isClosed) {
            modelController.addError(e);
          }
          return e as WrappedModel<T>;
        });
      }
    }
    if (wrappedModel?.isMarkedForRefresh ?? false) {
      wrappedModel?.isMarkedForRefresh = false;
    }
    return modelController;
  }

  @override
  Stream<ModelEvent<T>> watchAllChanges() {
    return _allModelEventsStreamController;
  }

  @override
  Stream<ModelEvent<T>> watchChanges(ModelID modelId) {
    ModelEvent<T>? selectModelChangeEvent(ModelEvent<T> event) {
      if (event.modelId == modelId) {
        return event;
      }
      return null;
    }

    final modelEventsController = _buildModelSpecificController(
      modelId,
      _allModelEventsStreamController,
      modelEventsStreamControllers,
      selectModelChangeEvent,
    );
    return modelEventsController;
  }

  BehaviorSubject<M> _buildModelSpecificController<A, M>(
    ModelID modelId,
    BehaviorSubject<A> allController,
    Map<ModelID, BehaviorSubject<M>> modelSpecificControllers,
    M? Function(A) selectReduceEvent,
  ) {
    // Reuse existing stream if any
    if (modelSpecificControllers.containsKey(modelId)) {
      return modelSpecificControllers[modelId]!;
    }

    // Construct a transformed stream that selects the corresponding object of
    // type [A] from the stream of all objects.
    //
    // It would be convenient to use a simple stream transform like .map here,
    // but this doesn't give us a way to send error events (e.g. from network
    // fetches) on the stream we are returning.
    //
    // Hence, we need to create a new controller here that implements
    // the stream transform as a subscription callback and cleans up after
    // itself when it's no longer needed.
    final BehaviorSubject<M> modelSpecificController = BehaviorSubject();

    final subscription = allController.listen((event) {
      final M? outputEvent = selectReduceEvent(event);
      if (outputEvent != null) {
        if (!modelSpecificController.isClosed) {
          modelSpecificController.add(outputEvent);
        }
      }
    });
    modelSpecificController.onCancel = () {
      subscription.cancel();
      modelSpecificController.close();
      modelSpecificControllers.remove(modelId);
    };

    modelSpecificControllers[modelId] = modelSpecificController;

    return modelSpecificController;
  }

  @override
  Future<WrappedModel<T>?> ensurePersisted(ModelID modelId) {
    final wrappedModel = get(modelId, strict: true)!;
    if (wrappedModel.isLocalOnly) {
      return save(wrappedModel.model);
    }
    return Future.value(wrappedModel);
  }

  WrappedModel<T> upsertLocally(T newModel, {bool emitUpdate = false}) {
    final newModelId = getKey(newModel);
    if (modelCache.containsKey(newModelId)) {
      // print("Upserting existing model $newModelId locally");
      // Model already exists, replace with the new object
      final wrapped = modelCache[newModelId]!;
      wrapped.model = newModel;
    } else {
      // Model does not exist locally yet, add it to the client-side list
      modelCache[newModelId] = WrappedModel(newModel);
    }
    if (emitUpdate) {
      this.emitUpdate();
    }
    return modelCache[newModelId]!;
  }

  List<WrappedModel<T>> upsertAllLocally(
    List<T> newModels, {
    bool emitUpdate = false,
  }) {
    final List<WrappedModel<T>> wrappedModels = [];
    for (final newModel in newModels) {
      final wrapped = upsertLocally(newModel);
      wrappedModels.add(wrapped);
    }
    if (emitUpdate) {
      this.emitUpdate();
    }
    return wrappedModels;
  }

  void emitUpdate() {
    if (!_allModelsStreamController.isClosed) {
      _allModelsStreamController.add(
        // Filter out models marked as deleted
        modelCache.values.where((model) => !model.isDeleted).toList(),
      );
    }
  }

  void emitModelEvent(ModelEvent<T> event) {
    if (!_allModelEventsStreamController.isClosed) {
      _allModelEventsStreamController.add(event);
    }
  }

  void emitError(
    StreamController? controller,
    Object e,
    StackTrace? stackTrace,
  ) {
    if (controller != null && !controller.isClosed) {
      controller.addError(e, stackTrace);
    }
    delegate.onError(e, stackTrace);
  }

  void markForRefresh(ModelID modelId) {
    final wrappedModel = get(modelId);
    if (wrappedModel != null) {
      wrappedModel.isMarkedForRefresh = true;
    }
  }

  @override
  void dispose() {
    _allModelsStreamController.close();
    _allModelEventsStreamController.close();
    for (final controller in modelStreamControllers.values.toList()) {
      controller.close();
    }
    for (final controller in modelEventsStreamControllers.values.toList()) {
      controller.close();
    }
  }

  @override
  List<ModelAction> availableActions(T model) {
    return []; // Subclass responsibility
  }
}
