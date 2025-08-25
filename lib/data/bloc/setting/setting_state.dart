// setting_state.dart
part of 'setting_bloc.dart';

enum SettingStatus { 
  initial, 
  loading, 
  loaded, 
  formInitialized,
  saving,
  saved,
  error 
}

final class SettingState extends Equatable {
  const SettingState({
    this.status = SettingStatus.initial,
    // this.chartDetailCount,
    this.furnaces = const [],
    this.matNumbers = const [],
    this.formState = const FormState(
      startDate: null,
      endDate: null,
      selectedItem: '',
      limitValue: '',
      periodValue: '', 
      selectedMatNo: '', 
      selectedConditions: [], 
      startDateLabel: 'Start Date', 
      endDateLabel: 'End Date', 
    ),
    this.errorMessage,
    // this.searchData,
  });

  final SettingStatus status;
  final List<Furnace> furnaces;
  final List<CustomerProduct> matNumbers;
  final FormState formState;
  final String? errorMessage;
  bool get isInitial => status == SettingStatus.initial;
  bool get isLoading => status == SettingStatus.loading;
  bool get isLoaded => status == SettingStatus.loaded;
  bool get isSaved => status == SettingStatus.saved;  

  SettingState copyWith({
    SettingStatus Function()? status,
    List<Furnace> Function()? furnaces,
    List<CustomerProduct> Function()? matNumbers,
    FormState Function()? formState,
    String? Function()? errorMessage,
  }) {
    return SettingState(
      status: status != null ? status() : this.status,
      furnaces: furnaces != null ? furnaces() : this.furnaces,
      matNumbers: matNumbers != null ? matNumbers() : this.matNumbers,
      formState: formState != null ? formState() : this.formState,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    furnaces,
    matNumbers,
    formState,
    errorMessage,
  ];
}