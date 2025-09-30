import 'package:flutter_bloc/flutter_bloc.dart';

class OptionsState {
  final bool loading;
  final String? error;
  final List<String> furnaceOptions;   // e.g. ["0","1","2"]
  final List<String> materialOptions;  // e.g. ["All Material No.","24009254"]
  final Map<String, String> cpNames;   // matNo -> cpName

  const OptionsState({
    required this.loading,
    required this.error,
    required this.furnaceOptions,
    required this.materialOptions,
    this.cpNames = const <String, String>{},
  });

  factory OptionsState.initial() => const OptionsState(
        loading: false,
        error: null,
        furnaceOptions: <String>[],
        materialOptions: <String>[],
        cpNames: <String, String>{},
      );

  OptionsState copyWith({
    bool? loading,
    String? error,
    List<String>? furnaceOptions,
    List<String>? materialOptions,
    Map<String, String>? cpNames,
  }) {
    return OptionsState(
      loading: loading ?? this.loading,
      error: error,
      furnaceOptions: furnaceOptions ?? this.furnaceOptions,
      materialOptions: materialOptions ?? this.materialOptions,
      cpNames: cpNames ?? this.cpNames,
    );
  }
}

typedef LoadFurnaces  = Future<List<String>> Function();
typedef LoadMaterials = Future<List<String>> Function();
typedef LoadCpNames   = Future<Map<String, String>> Function(); // cpNo -> cpName

class OptionsCubit extends Cubit<OptionsState> {
  OptionsCubit({
    required this.loadFurnaces,
    required this.loadMaterials,
    this.loadCpNames, // optional
  }) : super(OptionsState.initial());

  final LoadFurnaces loadFurnaces;
  final LoadMaterials loadMaterials;
  final LoadCpNames? loadCpNames;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      // load in parallel
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
}
