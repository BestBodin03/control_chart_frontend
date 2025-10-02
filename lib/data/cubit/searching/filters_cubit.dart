import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../screen/screen_content/home_screen_content/home_content_var.dart';
import '../../../ui/screen/screen_content/home_screen_content/home_content_var.dart';

class FiltersState {
  final String periodValue; // '1 เดือน' | '3 เดือน' | ... | 'กำหนดเอง'
  final DateTime? startDate;
  final DateTime? endDate;
  final HomeContentVar? lastAppliedProfile;

  const FiltersState({
    required this.periodValue,
    required this.startDate,
    required this.endDate,
    required this.lastAppliedProfile,
  });

  factory FiltersState.initial() => const FiltersState(
        periodValue: '1 month',
        startDate: null,
        endDate: null,
        lastAppliedProfile: null,
      );

  FiltersState copyWith({
    String? periodValue,
    DateTime? startDate,
    DateTime? endDate,
    HomeContentVar? lastAppliedProfile,
  }) {
    return FiltersState(
      periodValue: periodValue ?? this.periodValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastAppliedProfile: lastAppliedProfile ?? this.lastAppliedProfile,
    );
  }
}

class FiltersCubit extends Cubit<FiltersState> {
  FiltersCubit() : super(FiltersState.initial());

  void hydrate(DateTime? s, DateTime? e) {
    emit(state.copyWith(startDate: s ?? state.startDate, endDate: e ?? state.endDate));
  }

  void applyProfile(HomeContentVar p) {
    emit(state.copyWith(
      periodValue: 'Custom',
      startDate: p.startDate,
      endDate: p.endDate,
      lastAppliedProfile: p,
    ));
  }

  void setPeriod(String value, {DateTime? start, DateTime? end}) {
    emit(state.copyWith(periodValue: value, startDate: start, endDate: end));
  }

  void setStartDate(DateTime d) => emit(state.copyWith(periodValue: 'Custom', startDate: d));
  void setEndDate(DateTime d)   => emit(state.copyWith(periodValue: 'Custom', endDate: d));

  void refreshOneMonth() {
    final now = DateTime.now();
    final newStart = DateTime(now.year, now.month - 1, now.day);
    emit(state.copyWith(periodValue: '1 month', startDate: newStart, endDate: now));
  }
}
