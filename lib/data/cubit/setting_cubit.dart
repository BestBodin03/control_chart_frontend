import 'package:bloc/bloc.dart';
import 'package:control_chart/apis/settings/setting_filtering.dart';
import 'package:control_chart/data/cubit/setting_cubit_state.dart' show SettingCubitError, SettingCubitInitial, SettingCubitLoaded, SettingCubitLoading, SettingCubitState;

class SettingCubit extends Cubit<SettingCubitState> {
  final SettingFilteringApi  _apiService;
  
  SettingCubit(this._apiService) : super(SettingCubitInitial());
  
  Future<void> loadChartDetailCount() async {
    try {
      emit(SettingCubitLoading());
      final count = await _apiService.getChartDetailCount();
      emit(SettingCubitLoaded(count: count));
    } catch (e) {
      emit(SettingCubitError(message: e.toString()));
    }
  }
}