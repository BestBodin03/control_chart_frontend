import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../apis/settings/setting_apis.dart';

class OptionsCubit extends Cubit<OptionsState> {
  final SettingApis _settingApis;

  OptionsCubit({required SettingApis settingApis})
      : _settingApis = settingApis,
        super(OptionsState.initial());

  /// Load dropdown options for a specific row `index`
  /// Optionally filtered by `furnaceNo` and/or `cpNo`
  Future<void> loadDropdownOptions({
    required int index,
    String? furnaceNo,
    String? cpNo,
  }) async {
    debugPrint('🟡 [OptionsCubit] loadDropdownOptions(index=$index, furnaceNo=$furnaceNo, cpNo=$cpNo)');
    emit(state.copyWith(dropdownLoading: true));

    try {
      final json = await _settingApis.getSettingFormDropdown(
        furnaceNo: furnaceNo,
        cpNo: cpNo,
      );

      final payload = (json['data'] is Map<String, dynamic>)
          ? json['data'] as Map<String, dynamic>
          : (json as Map<String, dynamic>);

      List<String> toStringList(dynamic v) {
        if (v == null) return const <String>[];
        if (v is List) {
          return v.map((e) => e?.toString()).whereType<String>().toList();
        }
        return <String>[v.toString()];
      }

      // Keys from API
      final furnaces = toStringList(payload['furnaceNo']);
      final cps      = toStringList(payload['cpNo']);
      final cpNames = toStringList(payload['cpName']);

      // Update per-index maps
      final fBy = Map<int, List<String>>.from(state.furnaceOptionsByIndex);
      final cBy = Map<int, List<String>>.from(state.cpOptionsByIndex);
      final cnBy = Map<int, List<String>>.from(state.cpNameOptionsByIndex);
      fBy[index] = furnaces;
      cBy[index] = cps;

      emit(state.copyWith(
        dropdownLoading: false,
        furnaceOptionsByIndex: fBy,
        cpOptionsByIndex: cBy,
        lastFetchedFurnaces: furnaces,
        lastFetchedCps: cps,
        lastFetchedCpNames: cpNames
      ));

      debugPrint('🟢 [OptionsCubit] Updated index=$index | furnaces=${furnaces.length} cps=${cps.length}');
    } catch (e, st) {
      debugPrint('🔴 [OptionsCubit] loadDropdownOptions error: $e\n$st');
      emit(state.copyWith(dropdownLoading: false, error: e.toString()));
    }
  }
}

// ============== OptionsState ==============
class OptionsState extends Equatable {
  final bool dropdownLoading;

  /// Per-row options (keyed by index of the row/section that owns the dropdowns)
  final Map<int, List<String>> furnaceOptionsByIndex;
  final Map<int, List<String>> cpOptionsByIndex;
  final Map<int, List<String>> cpNameOptionsByIndex;

  /// Optional convenience: last payload fetched (useful for single dropdown UIs)
  final List<String> lastFetchedFurnaces;
  final List<String> lastFetchedCps;
  final List<String> lastFetchedCpNames;

  /// Optional: keep the last error (for debug/toast)
  final String? error;

  const OptionsState({
    required this.dropdownLoading,
    required this.furnaceOptionsByIndex,
    required this.cpOptionsByIndex,
    required this.cpNameOptionsByIndex,
    required this.lastFetchedFurnaces,
    required this.lastFetchedCps,
    required this.lastFetchedCpNames,
    required this.error,
  });

  factory OptionsState.initial() => const OptionsState(
        dropdownLoading: false,
        furnaceOptionsByIndex: <int, List<String>>{},
        cpOptionsByIndex: <int, List<String>>{},
        cpNameOptionsByIndex: <int, List<String>>{},
        lastFetchedFurnaces: <String>[],
        lastFetchedCps: <String>[],
        lastFetchedCpNames: <String>[],
        error: null,
      );

  OptionsState copyWith({
    bool? dropdownLoading,
    Map<int, List<String>>? furnaceOptionsByIndex,
    Map<int, List<String>>? cpOptionsByIndex,
    Map<int, List<String>>? cpNameOptionsByIndex,
    List<String>? lastFetchedFurnaces,
    List<String>? lastFetchedCps,
    List<String>? lastFetchedCpNames,
    String? error, // pass '' to clear, or null to keep
  }) {
    return OptionsState(
      dropdownLoading: dropdownLoading ?? this.dropdownLoading,
      furnaceOptionsByIndex:
      furnaceOptionsByIndex ?? this.furnaceOptionsByIndex,
      cpOptionsByIndex: cpOptionsByIndex ?? this.cpOptionsByIndex,
      cpNameOptionsByIndex: cpNameOptionsByIndex ?? this.cpNameOptionsByIndex,
      lastFetchedFurnaces: lastFetchedFurnaces ?? this.lastFetchedFurnaces,
      lastFetchedCps: lastFetchedCps ?? this.lastFetchedCps,
      lastFetchedCpNames: lastFetchedCpNames ?? this.lastFetchedCpNames,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        dropdownLoading,
        furnaceOptionsByIndex,
        cpOptionsByIndex,
        lastFetchedFurnaces,
        lastFetchedCps,
        error,
      ];
}
