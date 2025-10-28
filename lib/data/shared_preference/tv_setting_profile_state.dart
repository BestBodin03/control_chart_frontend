// lib/core/prefs/tv_setting_profile_state.dart

sealed class TvSettingProfileState {
  const TvSettingProfileState();
}

class TvSettingProfileEmpty extends TvSettingProfileState {
  const TvSettingProfileEmpty();
}

class TvSettingProfileLoaded extends TvSettingProfileState {
  final Map<String, dynamic> data;
  const TvSettingProfileLoaded(this.data);
}

class TvSettingProfileError extends TvSettingProfileState {
  final String message;
  const TvSettingProfileError(this.message);
}
