// delete_profiles_cubit.dart
import 'package:control_chart/data/cubit/setting_cubit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:control_chart/apis/settings/setting_apis.dart';

class DeleteProfilesCubit extends Cubit<DeleteProfilesState> {
  final SettingApis apis;
  DeleteProfilesCubit({required this.apis}) : super(const DeleteProfilesState());

  void toggleDeleteMode() {
    if (state.deleteMode) {
      // ปิดโหมด → เคลียร์ selection
      emit(state.copyWith(deleteMode: false, selected: {}));
    } else {
      emit(state.copyWith(deleteMode: true));
    }
  }

  void toggleSelected(String id) {
    final sel = Set<String>.from(state.selected);
    if (sel.contains(id)) {
      sel.remove(id);
    } else {
      sel.add(id);
    }
    emit(state.copyWith(selected: sel));
  }

  void clearSelected() => emit(state.copyWith(selected: {}));

  bool get canSubmit => state.deleteMode && state.selected.isNotEmpty;

  /// ลบรายการที่ถูกเลือกทั้งหมด
  Future<bool> removeSelected() async {
    if (!canSubmit) return false;

    emit(state.copyWith(status: SubmitStatus.submitting, error: null));
    try {
      // API ของคุณต้องรองรับ body {"ids":[...]}
      final res = await apis.removeSettingProfiles(ids: state.selected.toList());

      // 204/ไม่มี body → ถือว่าสำเร็จ
      final ok = (res == null) ? true : ((res['success'] as bool?) ?? true);
      final msg = res == null ? null : (res['message'] ?? res['error'])?.toString();

      if (ok) {
        // ปิดโหมด + ล้าง selection
        emit(const DeleteProfilesState(status: SubmitStatus.success));
        return true;
      } else {
        emit(state.copyWith(status: SubmitStatus.failure, error: msg ?? 'Failed to delete profile.'));
        return false;
      }
    } on DioException catch (e) {
      String err = e.message ?? 'Network error';
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        err = (data['message'] ?? data['error'] ?? err).toString();
      }
      emit(state.copyWith(status: SubmitStatus.failure, error: err));
      return false;
    } catch (e) {
      emit(state.copyWith(status: SubmitStatus.failure, error: e.toString()));
      return false;
    }
  }
}
