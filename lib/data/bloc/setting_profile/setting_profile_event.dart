part of 'setting_profile_bloc.dart';

sealed class SettingProfileEvent extends Equatable {
  const SettingProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAllSettingProfiles extends SettingProfileEvent {
  const LoadAllSettingProfiles();
}

final class RefreshSettingProfiles extends SettingProfileEvent {
  const RefreshSettingProfiles();
}
