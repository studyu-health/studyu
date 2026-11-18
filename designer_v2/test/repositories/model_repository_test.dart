import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class const _Model(final String id);

class _Delegate({final Future<_Model>? fetchResult})
    implements IModelRepositoryDelegate<_Model> {
  @override
  _Model createDuplicate(_Model model) => _Model('${model.id}-copy');

  @override
  _Model createNewInstance() => const _Model('new');

  @override
  Future<void> delete(_Model model) async => throw StateError('delete failed');

  @override
  Future<_Model> fetch(ModelID modelId) async =>
      await (fetchResult ?? Future.value(_Model(modelId)));

  @override
  Future<List<_Model>> fetchAll() async => const [];

  @override
  Future<_Model> save(_Model model) async => model;

  @override
  void onError(Object error, StackTrace? stackTrace) {}
}

class _Repository(_Delegate super.delegate) extends ModelRepository<_Model> {
  @override
  ModelID getKey(_Model model) => model.id;
}

void main() {
  test('watch forwards fetch errors without an unhandled cast error', () async {
    final fetched = Completer<_Model>();
    final repository = _Repository(_Delegate(fetchResult: fetched.future));
    addTearDown(repository.dispose);
    final error = StateError('study not found');

    final failure = expectLater(
      repository.watch('study'),
      emitsError(same(error)),
    );
    fetched.completeError(error);
    await failure;
    await Future<void>.delayed(Duration.zero);
  });

  test(
    'watch handles fetch errors after the subscription is cancelled',
    () async {
      final fetched = Completer<_Model>();
      final repository = _Repository(_Delegate(fetchResult: fetched.future));
      addTearDown(repository.dispose);
      final subscription = repository.watch('study').listen((_) {});
      await subscription.cancel();

      fetched.completeError(StateError('study not found'));
      await Future<void>.delayed(Duration.zero);
    },
  );

  test('watch emits the fetched model on success', () async {
    final repository = _Repository(_Delegate());
    addTearDown(repository.dispose);

    await expectLater(
      repository.watch('study'),
      emits(
        isA<WrappedModel<_Model>>().having(
          (wrapped) => wrapped.model.id,
          'study ID',
          'study',
        ),
      ),
    );
  });

  test('non-optimistic delete propagates persistence errors', () async {
    final repository = _Repository(_Delegate());
    repository.upsertLocally(const _Model('study')).markAsFetched();

    await expectLater(
      repository.delete('study', runOptimistically: false),
      throwsA(isA<StateError>()),
    );
    expect(repository.get('study'), isNotNull);
  });
}
