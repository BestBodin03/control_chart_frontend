// domain/types/form_state.dart
import 'package:equatable/equatable.dart';

class FormState extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final String selectedItem;
  final String limitValue;
  final String periodValue;
  final String selectedMatNo;
  final List<String> selectedConditions;
  final String startDateLabel;
  final String endDateLabel;

  const FormState({
    this.startDate,
    this.endDate,
    required this.selectedItem,
    required this.limitValue,
    required this.periodValue,
    required this.selectedMatNo,
    required this.selectedConditions,
    required this.startDateLabel,
    required this.endDateLabel,
  });

  // Factory constructor for initial state
  factory FormState.initial() {
    return FormState(
      startDate: null,
      endDate: null,
      selectedItem: '',
      limitValue: '9',
      periodValue: '1 เดือน',
      selectedMatNo: '',
      selectedConditions: const [],
      startDateLabel: '',
      endDateLabel: '',
    );
  }

  FormState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? selectedItem,
    String? limitValue,
    String? periodValue,
    String? selectedMatNo,
    List<String>? selectedConditions,
    String? startDateLabel,
    String? endDateLabel,
  }) {
    return FormState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedItem: selectedItem ?? this.selectedItem,
      limitValue: limitValue ?? this.limitValue,
      periodValue: periodValue ?? this.periodValue,
      selectedMatNo: selectedMatNo ?? this.selectedMatNo,
      selectedConditions: selectedConditions ?? this.selectedConditions,
      startDateLabel: startDateLabel ?? this.startDateLabel,
      endDateLabel: endDateLabel ?? this.endDateLabel,
    );
  }

  @override
  List<Object> get props => [
        startDate ?? DateTime(2024, 12, 30),
        endDate ?? DateTime(2020, 1, 1),
        selectedItem,
        limitValue,
        periodValue,
        selectedMatNo,
        selectedConditions,
        startDateLabel,
        endDateLabel,
      ];
}