// setting_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/types/form_state.dart';
import 'package:control_chart/utils/date_autocomplete.dart';
import 'package:equatable/equatable.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingApis _settingApis;
  final SearchBloc? searchBloc;

  SettingBloc({
    required SettingApis settingApis, 
    this.searchBloc,
  }) : _settingApis = settingApis,
       super(const SettingState()) {
    
    // Data loading events
    on<LoadChartDetailCount>(_onLoadChartDetailCount);
    on<LoadAllFurnaces>(_onLoadAllFurnaces);
    on<LoadAllMatNo>(_onLoadAllMatNo);
    on<LoadAllData>(_onLoadAllData);
    
    // Form events
    on<InitializeForm>(_onInitializeForm);
    on<SaveFormData>(_onSaveFormData);
    
    // Form update events
    on<UpdatePeriodS>(_onUpdatePeriodS);
    on<UpdateStartDate>(_onUpdateStartDate);
    on<UpdateEndDate>(_onUpdateEndDate);
    
    // Search events
    on<FilterChartDetailLoading>(_onFilterChartDetailLoading);
  }

  // Form event handlers
  Future<void> _onInitializeForm(
    InitializeForm event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(status: () => SettingStatus.loading));

    try {
      // Load initial data
      final results = await Future.wait([
        _settingApis.getAllFurnaces(),
        _settingApis.getAllMatNo(),
      ]);

      final furnaces = results[0] as List<Furnace>;
      final matNumbers = results[1] as List<CustomerProduct>;

      // Initialize form with default values and calculate initial dates
      final initialFormState = FormState.initial();
      final dateRanges = DateAutoComplete.calculateDateRange(initialFormState.periodValue);
      
      final updatedFormState = initialFormState.copyWith(
        startDate: dateRanges['startDate']!.date,
        endDate: dateRanges['endDate']!.date,
        startDateLabel: DateAutoComplete.formatDateLabel(dateRanges['startDate']!.date, true),
        endDateLabel: DateAutoComplete.formatDateLabel(dateRanges['endDate']!.date, false),
      );

      emit(state.copyWith(
        status: () => SettingStatus.formInitialized,
        formState: () => updatedFormState,
        furnaces: () => furnaces,
        matNumbers: () => matNumbers,
        errorMessage: () => null, // Clear any previous errors
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => SettingStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onSaveFormData(
    SaveFormData event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(status: () => SettingStatus.saving));

    try {
      // Add your save logic here
      // For example: await _settingApis.saveFormData(state.formState);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        status: () => SettingStatus.saved,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => SettingStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  // Data loading event handlers
  Future<void> _onLoadChartDetailCount(
    LoadChartDetailCount event,
    Emitter<SettingState> emit,
  ) async {
    // Keep existing data while loading
    emit(state.copyWith(status: () => SettingStatus.loading));

    try {
      final count = await _settingApis.getChartDetailCount();
      
      emit(state.copyWith(
        status: () => SettingStatus.loaded,
        chartDetailCount: () => count,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => SettingStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onLoadAllFurnaces(
    LoadAllFurnaces event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(status: () => SettingStatus.loading));

    try {
      final furnaces = await _settingApis.getAllFurnaces();
      
      emit(state.copyWith(
        status: () => SettingStatus.loaded,
        furnaces: () => furnaces,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => SettingStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onLoadAllMatNo(
    LoadAllMatNo event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(status: () => SettingStatus.loading));

    try {
      final matNumbers = await _settingApis.getAllMatNo();
      
      emit(state.copyWith(
        status: () => SettingStatus.loaded,
        matNumbers: () => matNumbers,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => SettingStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onLoadAllData(
    LoadAllData event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(status: () => SettingStatus.loading));

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _settingApis.getChartDetailCount(),
        _settingApis.getAllFurnaces(),
        _settingApis.getAllMatNo(),
      ]);

      emit(state.copyWith(
        status: () => SettingStatus.loaded,
        chartDetailCount: () => results[0] as int,
        furnaces: () => results[1] as List<Furnace>,
        matNumbers: () => results[2] as List<CustomerProduct>,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => SettingStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  // Form update event handlers
  Future<void> _onUpdatePeriodS(
    UpdatePeriodS event,
    Emitter<SettingState> emit,
  ) async {
    // Update UI state immediately
    final updatedFormState = state.formState.copyWith(
      periodValue: event.period,
    );
    
    emit(state.copyWith(formState: () => updatedFormState));

    // Calculate date range and update dates + labels
    final dateRange = DateAutoComplete.calculateDateRange(event.period);
    if (dateRange.isNotEmpty) {
      // Update start and end dates with calculated values
      final startDate = dateRange['startDate']!.date;
      final endDate = dateRange['endDate']!.date;
      
      final finalFormState = updatedFormState.copyWith(
        startDate: startDate,
        endDate: endDate,
        startDateLabel: DateAutoComplete.formatDateLabel(startDate, true),
        endDateLabel: DateAutoComplete.formatDateLabel(endDate, false),
      );

      emit(state.copyWith(formState: () => finalFormState));
    }
  }

  void _onUpdateStartDate(
    UpdateStartDate event,
    Emitter<SettingState> emit,
  ) {
    final newLabel = DateAutoComplete.formatDateLabel(event.startDate, true);
    
    final updatedFormState = state.formState.copyWith(
      startDate: event.startDate,
      startDateLabel: newLabel,
    );

    emit(state.copyWith(formState: () => updatedFormState));
  }

  void _onUpdateEndDate(
    UpdateEndDate event,
    Emitter<SettingState> emit,
  ) {
    final newLabel = DateAutoComplete.formatDateLabel(event.endDate, false);
    
    final updatedFormState = state.formState.copyWith(
      endDate: event.endDate,
      endDateLabel: newLabel,
    );

    emit(state.copyWith(formState: () => updatedFormState));
  }

  // Search event handler
  void _onFilterChartDetailLoading(
    FilterChartDetailLoading event,
    Emitter<SettingState> emit,
  ) {
    emit(state.copyWith(status: () => SettingStatus.loading));
    
    // This can trigger search in SearchBloc if needed
    // searchBloc?.add(SomeSearchEvent());
  }

  // Helper method for common error handling
  // void _handleError(Emitter<SettingState> emit, String error) {
  //   emit(state.copyWith(
  //     status: () => SettingStatus.error,
  //     errorMessage: () => error,
  //   ));
  // }
}