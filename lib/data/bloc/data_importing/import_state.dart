part of 'import_bloc.dart';

class ImportState extends Equatable {
  final String nameValue;
  final bool isWaiting;   // for _onStart
  final bool isPolling;   // while polling /progress
  final bool isAdding;    // for _onSubmit
  final String? error;    // ใช้เชิงโดเมนได้ตามเดิม (ไม่ผูก SnackBar โดยตรง)

  final DataImporting? importData;
  final Object? data;     // optional payload

  // 🔥 One-shot UI event for SnackBar
  final int snackId;          // เพิ่มทุกครั้งที่มี message ใหม่
  final String? snackMsg;     // ข้อความ
  final bool snackIsError;    // สีแดงหรือไม่

  const ImportState({
    this.nameValue = '',
    this.isWaiting = false,
    this.isPolling = false,
    this.isAdding = false,
    this.error,
    this.importData,
    this.data,
    this.snackId = 0,
    this.snackMsg,
    this.snackIsError = false,
  });

  bool get isBusy => isWaiting || isPolling || isAdding;

  ImportState copyWith({
    String? nameValue,
    bool? isWaiting,
    bool? isPolling,
    bool? isAdding,
    String? error,
    bool clearError = false,
    DataImporting? importData,
    Object? data,

    // 👇 ฟิลด์ของ snack
    int? snackId,
    String? snackMsg,
    bool? snackIsError,
    bool clearSnack = false, // ตั้ง true เพื่อล้าง snackMsg ถ้าต้องการ
  }) {
    return ImportState(
      nameValue: nameValue ?? this.nameValue,
      isWaiting: isWaiting ?? this.isWaiting,
      isPolling: isPolling ?? this.isPolling,
      isAdding:  isAdding  ?? this.isAdding,
      error: clearError ? null : (error ?? this.error),
      importData: importData ?? this.importData,
      data: data ?? this.data,

      snackId: snackId ?? this.snackId,
      snackMsg: clearSnack ? null : (snackMsg ?? this.snackMsg),
      snackIsError: snackIsError ?? this.snackIsError,
    );
  }

  @override
  List<Object?> get props => [
    nameValue, isWaiting, isPolling, isAdding, error, importData, data,
    // 👇 ต้องใส่ใน props เพื่อให้ listener/tracking เปลี่ยนทุกครั้ง
    snackId, snackMsg, snackIsError,
  ];
}
