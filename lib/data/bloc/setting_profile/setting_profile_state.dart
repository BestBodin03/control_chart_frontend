part of 'setting_profile_bloc.dart';

enum SettingProfileStatus {
  initial,
  loading,
  loaded,
  failed,
}

final class SettingProfileState extends Equatable {
  const SettingProfileState({
    this.status = SettingProfileStatus.initial,
    this.profiles = const [],
    this.count,
    this.errorMessage,
  });

  final SettingProfileStatus status;
  final List<Setting> profiles;
  final int? count;
  final String? errorMessage;

  bool get isInitial => status == SettingProfileStatus.initial;
  bool get isLoading => status == SettingProfileStatus.loading;
  bool get isLoaded  => status == SettingProfileStatus.loaded;
  bool get isFailed  => status == SettingProfileStatus.failed;

  SettingProfileState copyWith({
    SettingProfileStatus Function()? status,
    List<Setting> Function()? profiles,
    int? Function()? count,
    String? Function()? errorMessage,
  }) {
    return SettingProfileState(
      status: status != null ? status() : this.status,
      profiles: profiles != null ? profiles() : this.profiles,
      count: count != null ? count() : this.count,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profiles,
        count,
        errorMessage,
      ];
}
