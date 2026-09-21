import 'package:equatable/equatable.dart';

enum AppStatus() {
  initializing,
  initialized,
}

class const AppControllerState({
  final AppStatus status = AppStatus.initializing,
}) extends Equatable {
  bool get isInitialized => status == AppStatus.initialized;

  @override
  List<Object?> get props => [status];
}
