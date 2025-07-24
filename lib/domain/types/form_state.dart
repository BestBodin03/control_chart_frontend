class FormState {
  final DateTime startDate;
  final DateTime endDate;
  final String selectedItem;
  final String selectedMatNo;
  final String periodValue;
  final List<String> selectedConditions;
  final String limitValue;
  final String startDateLabel;
  final String endDateLabel;

  FormState({
    required this.startDate,
    required this.endDate,
    required this.selectedItem,
    required this.selectedMatNo,
    required this.periodValue,
    required this.selectedConditions,
    required this.limitValue,
    required this.startDateLabel,
    required this.endDateLabel,
  });

  FormState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? selectedItem,
    String? selectedMatNo,
    String? periodValue,
    List<String>? selectedConditions,
    String? limitValue,
    String? startDateLabel,
    String? endDateLabel,
  }) {
    return FormState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedItem: selectedItem ?? this.selectedItem,
      selectedMatNo: selectedMatNo ?? this.selectedMatNo,
      periodValue: periodValue ?? this.periodValue,
      selectedConditions: selectedConditions ?? this.selectedConditions,
      limitValue: limitValue ?? this.limitValue,
      startDateLabel: startDateLabel ?? this.startDateLabel,
      endDateLabel: endDateLabel ?? this.endDateLabel,
    );
  }
}