part of 'import_bloc.dart';

class ImportState extends Equatable {
  final DataImporting? data;
  final bool isSubmitting;
  final bool isPolling;
  final String? error;

  final String nameValue;
  final String dropdown1;
  final String dropdown2;

  const ImportState({
    this.data,
    this.isSubmitting = false,
    this.isPolling = false,
    this.error,
    this.nameValue = '',
    this.dropdown1 = '',
    this.dropdown2 = '',
  });

  ImportState copyWith({
    DataImporting? data,
    bool? isSubmitting,
    bool? isPolling,
    String? error, // set '' เพื่อล้างค่า
    String? nameValue,
    String? dropdown1,
    String? dropdown2,
  }) {
    return ImportState(
      data: data ?? this.data,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isPolling: isPolling ?? this.isPolling,
      error: error,
      nameValue: nameValue ?? this.nameValue,
      dropdown1: dropdown1 ?? this.dropdown1,
      dropdown2: dropdown2 ?? this.dropdown2,
    );
  }

  bool get isBusy => isSubmitting || isPolling;

  bool get showProgress {
    final d = data;
    if (d == null) return false;
    return d.isRunning || d.percent > 0 || d.isDone || d.hasError;
  }

  @override
  List<Object?> get props => [
        data,
        isSubmitting,
        isPolling,
        error,
        nameValue,
        dropdown1,
        dropdown2,
      ];
}
