import 'package:bloc/bloc.dart';
import 'package:control_chart/apis/api_response.dart';
import 'package:equatable/equatable.dart';

import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/domain/models/setting.dart';

part 'setting_profile_event.dart';
part 'setting_profile_state.dart';

class SettingProfileBloc extends Bloc<SettingProfileEvent, SettingProfileState> {
  final SettingApis _settingApis;

  SettingProfileBloc({required SettingApis settingApis})
      : _settingApis = settingApis,
        super(const SettingProfileState()) {
    on<LoadAllSettingProfiles>(_onLoadAllSettingProfiles);
    on<RefreshSettingProfiles>(_onRefreshSettingProfiles);
  }

Future<void> _onLoadAllSettingProfiles(
  LoadAllSettingProfiles event,
  Emitter<SettingProfileState> emit,
) async {
  emit(state.copyWith(status: () => SettingProfileStatus.loading));
  try {
    final settings = await _unwrapList<Setting>(_settingApis.getAllProfileSettings);
    emit(state.copyWith(
      status: () => SettingProfileStatus.loaded,
      profiles: () => settings,
      errorMessage: () => '',
    ));
  } catch (e) {
    emit(state.copyWith(
      status: () => SettingProfileStatus.failed,
      errorMessage: () => 'โหลดโปรไฟล์ไม่สำเร็จ: $e',
    ));
  }
}

Future<void> _onRefreshSettingProfiles(
  RefreshSettingProfiles event,
  Emitter<SettingProfileState> emit,
) async {
  try {
    final settings = await _unwrapList<Setting>(_settingApis.getAllProfileSettings);
    emit(state.copyWith(
      status: () => SettingProfileStatus.loaded,
      profiles: () => settings,
      errorMessage: () => '',
    ));
  } catch (e) {
    // คงข้อมูลเดิมไว้ แจ้ง error อย่างเดียว
    emit(state.copyWith(
      errorMessage: () => 'รีเฟรชโปรไฟล์ไม่สำเร็จ: $e',
    ));
  }
}

Future<List<T>> _unwrapList<T>(
  Future<ApiResponse<T>> Function() call,
) async {
  final resp = await call();
  if (!resp.success) {
    throw Exception(resp.error ?? 'Request failed');
  }
  return resp.data;
}

}
