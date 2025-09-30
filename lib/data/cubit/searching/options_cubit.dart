import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../apis/settings/setting_apis.dart';

class OptionsCubit extends Cubit<OptionsState> {
  final Future<List<String>> Function() loadFurnaces;
  final Future<List<String>> Function() loadMaterials;
  final Future<Map<String, String>>? Function()? loadCpNames;

  OptionsCubit({
    required this.loadFurnaces,
    required this.loadMaterials,
    this.loadCpNames,
  }) : super(OptionsState.initial());

  /// Initial load - loads all furnaces and materials
  Future<void> load() async {
    debugPrint('🟡 [OptionsCubit] Starting initial load...');
    emit(state.copyWith(loading: true));
    try {
      final furnaces = await loadFurnaces();
      debugPrint('🟡 [OptionsCubit] Loaded furnaces: $furnaces');
      
      final materials = await loadMaterials();
      debugPrint('🟡 [OptionsCubit] Loaded materials: $materials');
      
      // Load cpNames if function is provided
      Map<String, String> cpNamesMap = {};
      if (loadCpNames != null) {
        cpNamesMap = await loadCpNames!() ?? {};
        debugPrint('🟡 [OptionsCubit] Loaded cpNamesMap: $cpNamesMap');
      }
      
      // Convert map to parallel list matching materialOptions
      final cpNames = materials.map((matNo) => cpNamesMap[matNo] ?? '').toList();
      debugPrint('🟡 [OptionsCubit] Converted cpNames list: $cpNames');

      emit(state.copyWith(
        loading: false,
        furnaceOptions: furnaces,
        materialOptions: materials,
        cpNames: cpNames,
      ));
      debugPrint('🟡 [OptionsCubit] Initial load complete!');
    } catch (e) {
      debugPrint('🔴 [OptionsCubit] Error during load: $e');
      emit(state.copyWith(loading: false));
    }
  }

  /// Load materials filtered by furnace
  Future<void> loadMaterialsForFurnace(String? furnaceNo) async {
    debugPrint('🟡 [OptionsCubit] Loading materials for furnace: $furnaceNo');
    emit(state.copyWith(loading: true));
    try {
      // You can implement filtered loading here if needed
      // For now, just reload all materials
      final materials = await loadMaterials();
      debugPrint('🟡 [OptionsCubit] Reloaded materials: $materials');
      
      Map<String, String> cpNamesMap = {};
      if (loadCpNames != null) {
        cpNamesMap = await loadCpNames!() ?? {};
        debugPrint('🟡 [OptionsCubit] Reloaded cpNamesMap: $cpNamesMap');
      }
      
      final cpNames = materials.map((matNo) => cpNamesMap[matNo] ?? '').toList();
      debugPrint('🟡 [OptionsCubit] Converted cpNames list: $cpNames');

      emit(state.copyWith(
        loading: false,
        materialOptions: materials,
        cpNames: cpNames,
      ));
      debugPrint('🟡 [OptionsCubit] Material reload complete!');
    } catch (e) {
      debugPrint('🔴 [OptionsCubit] Error during material reload: $e');
      emit(state.copyWith(loading: false));
    }
  }
}

// ============== OptionsState ==============
class OptionsState extends Equatable {
  final bool loading;
  final List<String> furnaceOptions;
  final List<String> materialOptions;
  final List<String> cpNames; // Parallel to materialOptions

  const OptionsState({
    required this.loading,
    required this.furnaceOptions,
    required this.materialOptions,
    required this.cpNames,
  });

  factory OptionsState.initial() => const OptionsState(
        loading: false,
        furnaceOptions: [],
        materialOptions: [],
        cpNames: [],
      );

  OptionsState copyWith({
    bool? loading,
    List<String>? furnaceOptions,
    List<String>? materialOptions,
    List<String>? cpNames,
  }) {
    return OptionsState(
      loading: loading ?? this.loading,
      furnaceOptions: furnaceOptions ?? this.furnaceOptions,
      materialOptions: materialOptions ?? this.materialOptions,
      cpNames: cpNames ?? this.cpNames,
    );
  }

  @override
  List<Object?> get props => [loading, furnaceOptions, materialOptions, cpNames];
}