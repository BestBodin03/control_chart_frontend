import 'package:bloc/bloc.dart';
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/setting/setting_event.dart';
import 'package:control_chart/data/bloc/setting/setting_state.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/types/form_state.dart';
import 'package:control_chart/utils/date_autocomplete.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingApis _settingApis;

  SettingBloc({required SettingApis settingApis}) 
      : _settingApis = settingApis,
        super(FormDataState(
          formState: FormState(
            startDate: DateTime(2025, 12, 30),
            endDate: DateTime(2025, 7, 24),
            selectedItem: '',
            selectedMatNo: '',
            periodValue: '',
            selectedConditions: [],
            limitValue: '',
            startDateLabel: '',
            endDateLabel: '',
          ))) {
    
    on<LoadChartDetailCount>(_onLoadChartDetailCount);
    on<LoadAllFurnaces>(_onLoadAllFurnaces);
    on<LoadAllMatNo>(_onLoadAllMatNo);
    on<LoadAllData>(_onLoadAllData);
    on<SearchChartData>(_onSearchChartData);
    on<UpdatePeriod>(_onUpdatePeriod);
    on<UpdateStartDate>(_onUpdateStartDate);
    on<UpdateEndDate>(_onUpdateEndDate);
    on<UpdateSelectedItem>(_onUpdateSelectedItem);
    on<UpdateSelectedMatNo>(_onUpdateSelectedMatNo);
    on<UpdateSelectedConditions>(_onUpdateSelectedConditions);
    on<UpdateLimitValue>(_onUpdateLimitValue);
    on<SaveFormData>(_onSaveFormData);
  }

  Future<void> _onSearchChartData(
    SearchChartData event,
    Emitter<SettingState> emit,
  ) async {
    try {
      emit(SearchLoading());
      
      final data = await _settingApis.getFilteringChartDetails(
        furnaceNo: event.request.furnaceNo,
        matNo: event.request.matNo,
        startDate: event.request.startDate,
        endDate: event.request.endDate,
      );
      
      emit(SearchSuccess(data));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onLoadChartDetailCount(
    LoadChartDetailCount event,
    Emitter<SettingState> emit,
  ) async {
    try {
      emit(SettingLoading());
      final count = await _settingApis.getChartDetailCount();
      
      if (state is SettingLoaded) {
        emit((state as SettingLoaded).copyWith(chartDetailCount: count));
      } else {
        emit(SettingLoaded(chartDetailCount: count));
      }
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

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
        _settingApis.getChartDetails()
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
void _onUpdatePeriod(UpdatePeriod event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      
      // อัปเดต period และคำนวณวันที่ใหม่ถ้าไม่ใช่ "กำหนดเอง"
      DateTime newStartDate = currentState.formState.startDate;
      DateTime newEndDate = currentState.formState.endDate;
      String newStartLabel = currentState.formState.startDateLabel;
      String newEndLabel = currentState.formState.endDateLabel;
      
      if (event.period != 'กำหนดเอง') {
        final dateRanges = DateAutoComplete.calculateDateRange(event.period);
        newStartDate = dateRanges['startDate']!.date;
        newEndDate = dateRanges['endDate']!.date;
        newStartLabel = DateAutoComplete.formatDateLabel(newStartDate, true);
        newEndLabel = DateAutoComplete.formatDateLabel(newEndDate, false);
      }
      
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(
          periodValue: event.period,
          startDate: newStartDate,
          endDate: newEndDate,
          startDateLabel: newStartLabel,
          endDateLabel: newEndLabel,
        ),
      ));
    }
  }

  void _onUpdateStartDate(UpdateStartDate event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      final newLabel = DateAutoComplete.formatDateLabel(event.date, true);
      
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(
          startDate: event.date,
          startDateLabel: newLabel,
        ),
      ));
    }
  }

  void _onUpdateEndDate(UpdateEndDate event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      final newLabel = DateAutoComplete.formatDateLabel(event.date, false);
      
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(
          endDate: event.date,
          endDateLabel: newLabel,
        ),
      ));
    }
  }

  void _onUpdateSelectedItem(UpdateSelectedItem event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(selectedItem: event.item),
      ));
    }
  }

  void _onUpdateSelectedMatNo(UpdateSelectedMatNo event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(selectedMatNo: event.matNo),
      ));
    }
  }

  void _onUpdateSelectedConditions(UpdateSelectedConditions event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(selectedConditions: event.conditions),
      ));
    }
  }

  void _onUpdateLimitValue(UpdateLimitValue event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(limitValue: event.value),
      ));
    }
  }

  void _onSaveFormData(SaveFormData event, Emitter<SettingState> emit) {
    if (state is FormDataState) {
      final currentState = state as FormDataState;
      
      // แค่บันทึก - ไม่ส่ง URL
      print('Form saved with:');
      print('Start Date: ${currentState.formState.startDate}');
      print('End Date: ${currentState.formState.endDate}');
      print('Selected Item: ${currentState.formState.selectedItem}');
      print('Selected MatNo: ${currentState.formState.selectedMatNo}');
      print('Conditions: ${currentState.formState.selectedConditions}');
      print('Limit Value: ${currentState.formState.limitValue}');
      
      emit(currentState.copyWith(isSaved: true));
      
      // Reset saved state หลัง 2 วินาที
      Future.delayed(Duration(seconds: 2), () {
        if (state is FormDataState) {
          emit((state as FormDataState).copyWith(isSaved: false));
        }
      });
    }
  }

}

