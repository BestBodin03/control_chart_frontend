
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:control_chart/data/bloc/data_importing/extension/data_importing_copy.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
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

    on<_ImportProgressArrived>(_onProgressArrived);
    on<_ImportProgressFailed>(_onProgressFailed);
  }

void _emitSnack(Emitter<ImportState> emit, String msg, {bool error = false}) {
  emit(state.copyWith(
    snackId: state.snackId + 1, // ✅ บังคับให้ state เปลี่ยนทุกครั้ง
    snackMsg: msg,
    snackIsError: error,
  ));
}

  Future<void> _onSubmit(ImportSubmitPressed event, Emitter<ImportState> emit) async {
    if (state.isBusy) return;

    final mat = state.nameValue.trim();

    // 1) empty
    if (mat.isEmpty) {
      emit(state.copyWith(error: 'กรุณากรอก Material No.'));
      return;
    }

    // ตัวอย่างการใช้ใน validate
    if (!RegExp(r'^\d{8}$').hasMatch(mat)) {
      _emitSnack(emit, 'Material No. ต้องเป็นตัวเลข 8 หลักเท่านั้น', error: true);
      return;
    }

    // proceed
    emit(state.copyWith(isAdding: true, error: null));
    final resp = await _apis.addNewMaterial(mat);
    final newMatLenght = resp.data.length;

    if (!resp.success) {
      emit(state.copyWith(isAdding: false, error: resp.error ?? 'ส่งข้อมูลไม่สำเร็จ'));
      return;
    }

    if (resp.success) {
    emit(state.copyWith(
      isAdding: true,
      nameValue: '',
      data: resp.data, // เก็บทั้ง object ตามที่คุณต้องการ
    ));
    _emitSnack(emit, 'เพิ่มข้อมูลใหม่ $newMatLenght รายการ');
    }


    emit(state.copyWith(
      isAdding: false,
      nameValue: '',
      data: resp.data, // เก็บทั้ง object ตามที่คุณต้องการ
    ));
  }


Future<void> _onStart(ImportStartPressed event, Emitter<ImportState> emit) async {
  // กันกดซ้ำขณะกำลังทำงาน
  if (state.isWaiting || state.isPolling) return;

  _stopPolling();
  _postCompleteHideTimer?.cancel();

  // ✅ รีเซ็ตสถานะภาพรอบก่อน: ลบ percent เดิม/100% เดิม
  emit(state.copyWith(
    isWaiting: true,
    isPolling: false,
    importData: null,   // <-- สำคัญ: เคลียร์เพื่อไม่ให้ progress determinate ทันที
    error: null,
    // ถ้าอยากล้างผลก่อนหน้าในจออื่น ๆ ก็ล้าง data ด้วยได้ แต่ไม่จำเป็น
    // data: null,
  ));

  final resp = await _apis.process();
  if (!resp.success || resp.data.isEmpty) {
    emit(state.copyWith(isWaiting: false, error: resp.error ?? 'ไม่สามารถเริ่มการประมวลผลได้'));
    return;
  }

  emit(state.copyWith(isWaiting: false, isPolling: true, error: null));
  _startPolling(); // จะมีการยิง progress ครั้งแรกตามที่คุณเขียนไว้
}





 void _onProgressArrived(_ImportProgressArrived event, Emitter<ImportState> emit) {
  final d = event.data;
  final done = d.isDone || d.hasError || d.status == 'cancelled';

  emit(state.copyWith(
    importData: d,
    isPolling: !done,
    isWaiting: false,
    error: d.hasError
        ? (d.errors.isNotEmpty ? d.errors.join('\n') : 'เกิดข้อผิดพลาดในการนำเข้า')
        : null,
  ));

  if (done) {
    _stopPolling();
    _postCompleteHideTimer?.cancel();
    _postCompleteHideTimer = Timer(const Duration(seconds: 2), () {
      add(const _ImportProgressUiClear());
    });
  }
}

void _onProgressFailed(_ImportProgressFailed event, Emitter<ImportState> emit) {
  emit(state.copyWith(isPolling: false, isWaiting: false, error: event.message));
  _stopPolling();
  _postCompleteHideTimer?.cancel();
  _postCompleteHideTimer = Timer(const Duration(seconds: 2), () {
    add(const _ImportProgressUiClear());
  });
}

void _onCancel(ImportCancelPressed event, Emitter<ImportState> emit) {
  _stopPolling();
  emit(state.copyWith(isPolling: false, isWaiting: false, error: null));
}

void _onReset(ImportResetPressed event, Emitter<ImportState> emit) {
  _stopPolling();
  emit(const ImportState());
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