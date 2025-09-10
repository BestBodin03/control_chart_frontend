// delete_profiles_state.dart
import 'package:equatable/equatable.dart';

enum SubmitStatus { idle, submitting, success, failure }

class DeleteProfilesState extends Equatable {
  final bool deleteMode;        // อยู่ในโหมดลบไหม
  final Set<String> selected;   // id ที่ถูกเลือก
  final SubmitStatus status;    // สถานะส่งคำสั่งลบ
  final String? error;

  const DeleteProfilesState({
    this.deleteMode = false,
    this.selected = const {},
    this.status = SubmitStatus.idle,
    this.error,
  });

  DeleteProfilesState copyWith({
    bool? deleteMode,
    Set<String>? selected,
    SubmitStatus? status,
    String? error,
  }) {
    return DeleteProfilesState(
      deleteMode: deleteMode ?? this.deleteMode,
      selected: selected ?? this.selected,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [deleteMode, selected, status, error];
}
