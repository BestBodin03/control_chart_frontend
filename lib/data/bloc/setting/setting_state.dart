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
    this.chartDetailCount,
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
    this.searchData,
  });

  final SettingStatus status;
  final int? chartDetailCount;
  final List<Furnace> furnaces;
  final List<CustomerProduct> matNumbers;
  final FormState formState;
  final String? errorMessage;
  final Map<String, dynamic>? searchData;

  // Computed properties for convenience
  bool get isInitial => status == SettingStatus.initial;
  bool get isLoading => status == SettingStatus.loading;
  bool get isLoaded => status == SettingStatus.loaded;
  bool get isFormInitialized => status == SettingStatus.formInitialized;
  bool get isSaving => status == SettingStatus.saving;
  bool get isSaved => status == SettingStatus.saved;  
  bool get hasError => status == SettingStatus.error;
  bool get hasFurnaces => furnaces.isNotEmpty;
  bool get hasMatNumbers => matNumbers.isNotEmpty;
  bool get hasChartDetailCount => chartDetailCount != null;
  bool get hasSearchData => searchData != null;

  SettingState copyWith({
    SettingStatus Function()? status,
    int? Function()? chartDetailCount,
    List<Furnace> Function()? furnaces,
    List<CustomerProduct> Function()? matNumbers,
    FormState Function()? formState,
    String? Function()? errorMessage,
    Map<String, dynamic>? Function()? searchData,
  }) {
    return SettingState(
      status: status != null ? status() : this.status,
      chartDetailCount: chartDetailCount != null 
          ? chartDetailCount() : this.chartDetailCount,
      furnaces: furnaces != null ? furnaces() : this.furnaces,
      matNumbers: matNumbers != null ? matNumbers() : this.matNumbers,
      formState: formState != null ? formState() : this.formState,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      searchData: searchData != null ? searchData() : this.searchData,
    );
  }

  @override
  List<Object?> get props => [
    status,
    chartDetailCount,
    furnaces,
    matNumbers,
    formState,
    errorMessage,
    searchData,
  ];
}