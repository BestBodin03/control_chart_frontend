// data/bloc/setting/setting_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_event.dart';
import 'package:control_chart/data/bloc/setting/setting_event.dart';
import 'package:control_chart/data/bloc/setting/setting_state.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/types/form_state.dart';
import 'package:control_chart/utils/date_autocomplete.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingApis _settingApis;
  final SearchBloc? searchBloc;

  SettingBloc({required SettingApis settingApis, this.searchBloc}) 
      : _settingApis = settingApis,
        super(SettingInitial()) {
    
    // on<LoadChartDetailCount>(_onLoadChartDetailCount);
    on<LoadAllFurnaces>(_onLoadAllFurnaces);
    on<LoadAllMatNo>(_onLoadAllMatNo);
    on<LoadAllData>(_onLoadAllData);
    // on<SearchChartData>(_onSearchChartData);

    on<UpdatePeriodS>(_onUpdatePeriodS);
    on<UpdateStartDate>(_onUpdateStartDate);
    on<UpdateEndDate>(_onUpdateEndDate);
    
    // Form event handlers
    on<InitializeForm>(_onInitializeForm);
    on<SaveFormData>(_onSaveFormData);
  }

  // Form event handlers
  void _onInitializeForm(InitializeForm event, Emitter<SettingState> emit) async {
    try {
      emit(SettingLoading());
      
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

      emit(FormDataState(
        formState: updatedFormState,
        furnaces: furnaces,
        matNumbers: matNumbers,
      ));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  void _onSaveFormData(SaveFormData event, Emitter<SettingState> emit) async {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      emit(currentState.copyWith(isLoading: true));
      
      try {
        // Add your save logic here
        // For example: await _settingApis.saveFormData(currentState.formState);
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        emit(currentState.copyWith(isLoading: false, isSaved: true));
      } catch (e) {
        emit(currentState.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  // Future<void> _onLoadChartDetailCount(
  //   LoadChartDetailCount event,
  //   Emitter<SettingState> emit,
  // ) async {
  //   try {
  //     emit(SettingLoading());
  //     // final count = await _settingApis.getChartDetailCount();
      
  //     if (state is SettingLoaded) {
  //       emit((state as SettingLoaded).copyWith(chartDetailCount: count));
  //     } else {
  //       emit(SettingLoaded(chartDetailCount: count));
  //     }
  //   } catch (e) {
  //     emit(SettingError(e.toString()));
  //   }
  // }

  Future<void> _onLoadAllFurnaces(
    LoadAllFurnaces event,
    Emitter<SettingState> emit,
  ) async {
    try {
      emit(SettingLoading());
      final furnaces = await _settingApis.getAllFurnaces();
      
      if (state is SettingLoaded) {
        emit((state as SettingLoaded).copyWith(furnaces: furnaces));
      } else {
        emit(SettingLoaded(furnaces: furnaces));
      }
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  Future<void> _onLoadAllMatNo(
    LoadAllMatNo event,
    Emitter<SettingState> emit,
  ) async {
    try {
      emit(SettingLoading());
      final matNumbers = await _settingApis.getAllMatNo();
      
      if (state is SettingLoaded) {
        emit((state as SettingLoaded).copyWith(matNumbers: matNumbers));
      } else {
        emit(SettingLoaded(matNumbers: matNumbers));
      }
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  Future<void> _onLoadAllData(
    LoadAllData event,
    Emitter<SettingState> emit,
  ) async {
    try {
      emit(SettingLoading());
      
      // Load all data concurrently
      final results = await Future.wait([
        _settingApis.getChartDetailCount(),
        _settingApis.getAllFurnaces(),
        _settingApis.getAllMatNo(),
      ]);

      emit(SettingLoaded(
        chartDetailCount: results[0] as int,
        furnaces: results[1] as List<Furnace>,
        matNumbers: results[2] as List<CustomerProduct>,
      ));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

Future<void> _onUpdatePeriodS(
    UpdatePeriodS event,
    Emitter<SettingState> emit,
  ) async {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      
      // อัพเดท UI state
      final updatedFormState = currentState.formState.copyWith(
        periodValue: event.period,
      );
      
      emit(currentState.copyWith(formState: updatedFormState));

      // Calculate date range and update dates + labels
      final dateRange = DateAutoComplete.calculateDateRange(event.period);
      if (dateRange.isNotEmpty) {
        // Call the existing methods to update start and end dates with labels
        _onUpdateStartDate(
          UpdateStartDate(startDate: dateRange['startDate']!.date), 
          emit
        );
        _onUpdateEndDate(
          UpdateEndDate(endDate: dateRange['endDate']!.date), 
          emit
        );
      }
    }
  }

  void _onUpdateStartDate(UpdateStartDate event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      final newLabel = DateAutoComplete.formatDateLabel(event.startDate, true);
      
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(
          startDate: event.startDate,
          startDateLabel: newLabel,
        ),
      ));
    }
  }

  void _onUpdateEndDate(UpdateEndDate event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      final newLabel = DateAutoComplete.formatDateLabel(event.endDate, false);
      
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(
          endDate: event.endDate,
          endDateLabel: newLabel,
        ),
      ));
    }
  }

}