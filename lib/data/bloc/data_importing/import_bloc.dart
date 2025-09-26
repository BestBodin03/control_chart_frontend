
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:control_chart/data/bloc/data_importing/extension/data_importing_copy.dart';
import 'package:equatable/equatable.dart';

import '../../../apis/api_response.dart';
import '../../../apis/import_data/import_data_apis.dart';
import '../../../config/api_config.dart';
import '../../../domain/models/data_importing.dart';

part 'import_event.dart';
part 'import_state.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ImportDataApis _apis;
  final Duration _interval;

  StreamSubscription? _pollSub;
    // ==== เพิ่มฟิลด์ ====
  Timer? _postCompleteHideTimer;

  ImportBloc({
    ImportDataApis? apis,
    Duration interval = const Duration(seconds: 1),
    ImportState? initial,
  })  : _apis = apis ?? ImportDataApis(api: ApiConfig()),
        _interval = interval,
        super(initial ?? const ImportState()) {
    on<ImportStartPressed>(_onStart);
    on<ImportCancelPressed>(_onCancel);
    on<ImportResetPressed>(_onReset);
    on<_ImportProgressUiClear>(_onProgressUiClear);
    on<ImportSubmitPressed>(_onSubmit); 

    on<ImportNameChanged>((e, emit) {
      emit(state.copyWith(nameValue: e.value, error: state.error));
    });
    on<ImportDropdown1Changed>((e, emit) {
      emit(state.copyWith(dropdown1: e.value, error: state.error));
    });
    on<ImportDropdown2Changed>((e, emit) {
      emit(state.copyWith(dropdown2: e.value, error: state.error));
    });

    on<_ImportProgressArrived>(_onProgressArrived);
    on<_ImportProgressFailed>(_onProgressFailed);
  }

 Future<void> _onSubmit(ImportSubmitPressed event, Emitter<ImportState> emit) async {
    if (state.isBusy) return; // กันกดระหว่างกำลัง process/polling/submitting

    final String mat = state.nameValue.trim();
    if (mat.isEmpty) {
      emit(state.copyWith(error: 'กรุณากรอก Material No.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, error: null));

    final resp = await _apis.addNewMaterial(mat);
    if (!resp.success) {
      emit(state.copyWith(isSubmitting: false, error: resp.error ?? 'ส่งข้อมูลไม่สำเร็จ'));
      return;
    }

    // สำเร็จ: เคลียร์ฟิลด์ / ปิดโหลด
    emit(state.copyWith(
      isSubmitting: false,
      nameValue: '',   // ล้างช่องกรอก
    ));
  }

// ==== START: ไม่อัด percent จาก process ====
Future<void> _onStart(ImportStartPressed event, Emitter<ImportState> emit) async {
  if (state.isBusy) return;

  // เริ่มใหม่: ล้าง data เพื่อให้ UI เป็น indeterminate ก่อน
  _postCompleteHideTimer?.cancel();
  emit(state.copyWith(isSubmitting: true, isPolling: false, data: null, error: null));

  final resp = await _apis.process();
  if (!resp.success || resp.data.isEmpty) {
    emit(state.copyWith(isSubmitting: false, error: resp.error ?? 'ไม่สามารถเริ่มการประมวลผลได้'));
    return;
  }

  // อย่าแตะ data/percent ที่ได้จาก process
  emit(state.copyWith(isSubmitting: false, isPolling: true, error: null));
  _startPolling(); // ยิง /progress ทุกวินาที (มียิงรอบแรกทันที)
}



  void _onCancel(ImportCancelPressed event, Emitter<ImportState> emit) {
    _stopPolling();
    emit(state.copyWith(isPolling: false, isSubmitting: false, error: null));
  }

  void _onReset(ImportResetPressed event, Emitter<ImportState> emit) {
    _stopPolling();
    emit(const ImportState());
  }


// ==== มาถึง progress ====
void _onProgressArrived(_ImportProgressArrived event, Emitter<ImportState> emit) {
  final d = event.data;
  final done = d.isDone || d.hasError || d.status == 'cancelled';

  emit(state.copyWith(
    data: d,                 // ใช้ percent ที่มาจาก /progress เท่านั้น
    isPolling: !done,
    isSubmitting: false,
    error: d.hasError
        ? (d.errors.isNotEmpty ? d.errors.join('\n') : 'เกิดข้อผิดพลาดในการนำเข้า')
        : null,
  ));

  if (done) {
    _stopPolling();
    _postCompleteHideTimer?.cancel();
    // ซ่อนแถบภายใน 2 วินาที
    _postCompleteHideTimer = Timer(const Duration(seconds: 2), () {
      add(const _ImportProgressUiClear());
    });
  }
}

void _onProgressFailed(_ImportProgressFailed event, Emitter<ImportState> emit) {
  emit(state.copyWith(isPolling: false, isSubmitting: false, error: event.message));
  _stopPolling();
  _postCompleteHideTimer?.cancel();
  // ซ่อนหลัง 2 วิ เช่นกัน
  _postCompleteHideTimer = Timer(const Duration(seconds: 2), () {
    add(const _ImportProgressUiClear());
  });
}

void _onProgressUiClear(_ImportProgressUiClear event, Emitter<ImportState> emit) {
  emit(state.copyWith(data: null)); // ทำให้ UI หาย progress
}

void _stopPolling() {
  _pollSub?.cancel();
  _pollSub = null;
}

@override
Future<void> close() {
  _postCompleteHideTimer?.cancel();
  _stopPolling();
  return super.close();
}



// ==== โพลล์: ใช้ /progress อย่างเดียว ====
void _startPolling() {
  _stopPolling();

  _pollSub = Stream<void>.periodic(_interval)
      .asyncMap((_) => _apis.progress())
      .listen((resp) {
    if (!resp.success || resp.data.isEmpty) {
      add(_ImportProgressFailed(resp.error ?? 'ดึงความคืบหน้าไม่ได้'));
      return;
    }
    try {
      add(_ImportProgressArrived(DataImporting.fromJson(resp.data.first)));
    } catch (e) {
      add(_ImportProgressFailed('โครงสร้างข้อมูล progress ไม่ถูกต้อง: $e'));
    }
  }, onError: (e, __) {
    add(_ImportProgressFailed(e.toString()));
  });

  () async {
    final first = await _apis.progress();
    if (!first.success || first.data.isEmpty) {
      add(_ImportProgressFailed(first.error ?? 'ดึงความคืบหน้าไม่ได้'));
      return;
    }
    try {
      add(_ImportProgressArrived(DataImporting.fromJson(first.data.first)));
    } catch (e) {
      add(_ImportProgressFailed('โครงสร้างข้อมูล progress ไม่ถูกต้อง: $e'));
    }
  }();
}



/// helper: หลอม percent เข้ากับสเตตเดิม
DataImporting _withPercent(DataImporting? base, int percent) {
  return DataImporting(
    jobId: base?.jobId ?? 'temp',
    status: base?.status ?? 'running',
    startedAt: base?.startedAt ?? DateTime.now().millisecondsSinceEpoch,
    finishedAt: base?.finishedAt,
    total: base?.total ?? 0,
    completed: base?.completed ?? 0,
    success: base?.success ?? 0,
    failed: base?.failed ?? 0,
    percent: percent.clamp(0, 100),
    lastItem: base?.lastItem,
    errors: base?.errors ?? const [],
  );
}
}