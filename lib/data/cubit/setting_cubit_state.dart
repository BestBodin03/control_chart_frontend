abstract class SettingCubitState {}

class SettingCubitInitial extends SettingCubitState {}

class SettingCubitLoading extends SettingCubitState {}

class SettingCubitLoaded extends SettingCubitState {
  final int count;
  SettingCubitLoaded({required this.count});
}

class SettingCubitError extends SettingCubitState {
  final String message;
  SettingCubitError({required this.message});
}