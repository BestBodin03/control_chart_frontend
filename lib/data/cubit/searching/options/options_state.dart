import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ---------- Data from your dropdown source ----------
@immutable
class DropdownPayload {
  final List<String> furnaceNos;               // ["0","1","2"]
  final List<String> cpNos;                    // ["24001234","24005678"]
  final Map<String, String> cpNamesByNo;       // cpNo -> cpName

  const DropdownPayload({
    required this.furnaceNos,
    required this.cpNos,
    required this.cpNamesByNo,
  });
}

/// ---------- State ----------
@immutable
class OptionsState {
  final bool loading;            // initial/global load
  final bool dropdownLoading;    // dependent dropdown load
  final String? error;

  final List<String> furnaceOptions;   // ["0","1","2"]
  final List<String> materialOptions;  // ["All Material Nos.","24009254"]
  final List<String> cpNos;            // ["24001234","24005678"]
  final Map<String, String> cpNames;   // cpNo -> cpName

  const OptionsState({
    required this.loading,
    required this.dropdownLoading,
    required this.error,
    required this.furnaceOptions,
    required this.materialOptions,
    required this.cpNos,
    required this.cpNames,
  });

  factory OptionsState.initial() => const OptionsState(
        loading: false,
        dropdownLoading: false,
        error: null,
        furnaceOptions: <String>[],
        materialOptions: <String>[],
        cpNos: <String>[],
        cpNames: <String, String>{},
      );

  /// Labels ready for UI: ["All Material Nos.", "24001234 - CP A", ...]
  List<String> get cpDisplayOptions {
    final list = cpNos.map((no) {
      final name = cpNames[no];
      return (name != null && name.isNotEmpty) ? '$no - $name' : no;
    }).toList();
    return <String>['All Material Nos.', ...list];
  }

  OptionsState copyWith({
    bool? loading,
    bool? dropdownLoading,
    String? error, // pass null to clear
    List<String>? furnaceOptions,
    List<String>? materialOptions,
    List<String>? cpNos,
    Map<String, String>? cpNames,
  }) {
    return OptionsState(
      loading: loading ?? this.loading,
      dropdownLoading: dropdownLoading ?? this.dropdownLoading,
      error: error,
      furnaceOptions: furnaceOptions ?? this.furnaceOptions,
      materialOptions: materialOptions ?? this.materialOptions,
      cpNos: cpNos ?? this.cpNos,
      cpNames: cpNames ?? this.cpNames,
    );
  }
}

/// ---------- Loaders (pure functions you inject) ----------
typedef LoadFurnaces  = Future<List<String>> Function();
typedef LoadMaterials = Future<List<String>> Function();
typedef LoadCpNames   = Future<Map<String, String>> Function(); // optional cache
typedef LoadDropdown  = Future<DropdownPayload> Function({
  String? furnaceNo,
  String? cpNo,
});

/// ---------- Cubit ----------
class OptionsCubit extends Cubit<OptionsState> {
  OptionsCubit({
    required this.loadFurnaces,
    required this.loadMaterials,
    required this.loadDropdown,
    this.loadCpNames,
  }) : super(OptionsState.initial());

  final LoadFurnaces loadFurnaces;
  final LoadMaterials loadMaterials;
  final LoadDropdown loadDropdown;
  final LoadCpNames? loadCpNames;

  /// Initial/global load
  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final furnacesF  = loadFurnaces();
      final materialsF = loadMaterials();
      final cpNamesF   = loadCpNames?.call();

      final furnaces  = await furnacesF;
      final materials = await materialsF;
      final cpNames   = cpNamesF != null ? await cpNamesF : state.cpNames;

      emit(state.copyWith(
        loading: false,
        furnaceOptions: furnaces,
        materialOptions: materials,
        cpNames: cpNames,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: '$e'));
    }
  }

  /// Dependent dropdown (global; no index)
  Future<void> loadDropdownOptions({String? furnaceNo, String? cpNo}) async {
    emit(state.copyWith(dropdownLoading: true, error: null));
    try {
      final p = await loadDropdown(furnaceNo: furnaceNo, cpNo: cpNo);

      // merge names (retain old, override with new)
      final mergedNames = <String, String>{}
        ..addAll(state.cpNames)
        ..addAll(p.cpNamesByNo);

      emit(state.copyWith(
        dropdownLoading: false,
        furnaceOptions: p.furnaceNos.isEmpty ? state.furnaceOptions : p.furnaceNos,
        cpNos: p.cpNos,
        cpNames: mergedNames,
      ));
    } catch (e) {
      emit(state.copyWith(dropdownLoading: false, error: '$e'));
    }
  }
}
