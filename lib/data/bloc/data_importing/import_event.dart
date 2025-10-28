part of 'import_bloc.dart';

abstract class ImportEvent {
  const ImportEvent();
}

class ImportStartPressed extends ImportEvent {
  const ImportStartPressed();
}

class ImportCancelPressed extends ImportEvent {
  const ImportCancelPressed();
}

class ImportResetPressed extends ImportEvent {
  const ImportResetPressed();
}

class ImportNameChanged extends ImportEvent {
  final String value;
  const ImportNameChanged(this.value);
}

class ImportDropdown1Changed extends ImportEvent {
  final String value;
  const ImportDropdown1Changed(this.value);
}

class ImportDropdown2Changed extends ImportEvent {
  final String value;
  const ImportDropdown2Changed(this.value);
}

/// ภายใน (private to library)
class _ImportProgressArrived extends ImportEvent {
  final DataImporting data;
  const _ImportProgressArrived(this.data);
}

class _ImportProgressFailed extends ImportEvent {
  final String message;
  const _ImportProgressFailed(this.message);
}

class _ImportProgressUiClear extends ImportEvent {
  const _ImportProgressUiClear();
}

class ImportSubmitPressed extends ImportEvent { 
  const ImportSubmitPressed(); 
}

// ==== on<...> ใน constructor ====
