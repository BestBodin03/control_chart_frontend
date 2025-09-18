import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/domain/models/setting.dart';

extension SettingFormCubitGlobalPeriod on SettingFormCubit {
  
  /// Update global period type and propagate to all specifics
  void updateGlobalPeriodType(PeriodType periodType) {
    emit(state.copyWith(globalPeriodType: periodType));
    
    // Update all specifics with the same period type
    final updatedSpecifics = state.specifics.map((sp) => 
      sp.copyWith(periodType: periodType)
    ).toList();
    
    emit(state.copyWith(specifics: updatedSpecifics));
  }

  /// Update global start date and propagate to all specifics
  void updateGlobalStartDate(DateTime startDate) {
    emit(state.copyWith(
      globalStartDate: startDate,
      globalPeriodType: PeriodType.CUSTOM,
    ));
    
    // Update all specifics with the same start date
    final updatedSpecifics = state.specifics.map((sp) => 
      sp.copyWith(
        startDate: startDate,
        periodType: PeriodType.CUSTOM,
      )
    ).toList();
    
    emit(state.copyWith(specifics: updatedSpecifics));
  }

  /// Update global end date and propagate to all specifics
  void updateGlobalEndDate(DateTime endDate) {
    emit(state.copyWith(
      globalEndDate: endDate,
      globalPeriodType: PeriodType.CUSTOM,
    ));
    
    // Update all specifics with the same end date
    final updatedSpecifics = state.specifics.map((sp) => 
      sp.copyWith(
        endDate: endDate,
        periodType: PeriodType.CUSTOM,
      )
    ).toList();
    
    emit(state.copyWith(specifics: updatedSpecifics));
  }

  /// Update all global period settings at once
  void updateGlobalPeriod(PeriodType periodType, DateTime? startDate, DateTime? endDate) {
    emit(state.copyWith(
      globalPeriodType: periodType,
      globalStartDate: startDate,
      globalEndDate: endDate,
    ));
    
    // Update all specifics with the same period settings
    final updatedSpecifics = state.specifics.map((sp) => 
      sp.copyWith(
        periodType: periodType,
        startDate: startDate,
        endDate: endDate,
      )
    ).toList();
    
    emit(state.copyWith(specifics: updatedSpecifics));
  }

  /// Initialize global period from existing data
  void initializeGlobalPeriod() {
    if (state.specifics.isNotEmpty) {
      final first = state.specifics.first;
      emit(state.copyWith(
        globalPeriodType: first.periodType,
        globalStartDate: first.startDate,
        globalEndDate: first.endDate,
      ));
    }
  }
}