import 'package:studyu_designer_v2/repositories/model_repository.dart';

abstract class const ModelEvent<T>(final ModelID modelId, final T model);

class const IsFetched<T>(super.modelId, super.model) extends ModelEvent<T>;

class const IsSaving<T>(super.modelId, super.model) extends ModelEvent<T>;

class const IsSaved<T>(super.modelId, super.model) extends ModelEvent<T>;

class const IsDeleted<T>(super.modelId, super.model) extends ModelEvent<T>;
