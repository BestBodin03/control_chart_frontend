// search_bloc.dart
import 'package:control_chart/apis/search_chart_details/search_chart_details_apis.dart';
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/domain/types/search_table.dart';
import 'package:control_chart/domain/types/tv_query.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchChartDetailsApis _searchApiService;
  final SettingApis _settingApis;

  SearchBloc({
    SearchChartDetailsApis? searchApiService,
    SettingApis? settingApiService,
  })  : _searchApiService = searchApiService ?? SearchChartDetailsApis(),
        _settingApis = settingApiService ?? SettingApis(),
        super(const SearchState()) {
    on<LoadFilteredChartData>(_onLoadFilteredChartData);
    on<LoadTvChartData>(_onLoadTvChartData);
    on<ClearFilters>(_onClearFilters);
    on<UpdateDateRange>(_onUpdateDateRange);

    // ▼ NEW: dropdown events
    on<LoadDropdownOptions>(_onLoadDropdownOptions);
    on<SelectFurnace>(_onSelectFurnace);
    on<SelectMaterial>(_onSelectMaterial);
  }

  // ---------------- existing handlers ----------------

  Future<void> _onLoadTvChartData(
    LoadTvChartData event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final newQuery = TvQuery(
        startDate: event.startDate,
        endDate: event.endDate,
        furnaceNo: event.furnaceNo,
        materialNo: event.materialNo,
      );

      final results = await Future.wait([
        _searchApiService.getTvChartDetails(newQuery),
        _searchApiService.getTvControlChartStat(newQuery),
      ]);

      final (chartDetails, searchTables) =
          results[0] as (List<ChartDetail>, List<SearchTable>);
      final chartStatistics = results[1] as ControlChartStats;

      emit(state.copyWith(
        status: () => SearchStatus.success,
        chartDetails: () => chartDetails,
        searchTable: () => searchTables,
        controlChartStats: () => chartStatistics,
        tvQuery: () => newQuery,
        errorMessage: () => null,
      ));
    } catch (e) {
      final newQuery = TvQuery(
        startDate: event.startDate,
        endDate: event.endDate,
        furnaceNo: event.furnaceNo,
        materialNo: event.materialNo,
      );
      emit(state.copyWith(
        status: () => SearchStatus.failure,
        tvQuery: () => newQuery,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onLoadFilteredChartData(
    LoadFilteredChartData event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final newQuery = ChartFilterQuery(
        startDate: event.startDate,
        endDate: event.endDate,
        furnaceNo: event.furnaceNo,
        materialNo: event.materialNo,
      );

      final results = await Future.wait([
        _searchApiService.getFilteringChartDetails(newQuery),
        _searchApiService.getControlChartStat(newQuery),
      ]);

      final (chartDetails, searchTables) =
          results[0] as (List<ChartDetail>, List<SearchTable>);
      final chartStatistics = results[1] as ControlChartStats;

      emit(state.copyWith(
        status: () => SearchStatus.success,
        chartDetails: () => chartDetails,
        searchTable: () => searchTables,
        controlChartStats: () => chartStatistics,
        currentQuery: () => newQuery,
        errorMessage: () => null,
      ));
    } catch (e) {
      final newQuery = ChartFilterQuery(
        startDate: event.startDate,
        endDate: event.endDate,
        furnaceNo: event.furnaceNo,
        materialNo: event.materialNo,
      );
      emit(state.copyWith(
        status: () => SearchStatus.failure,
        currentQuery: () => newQuery,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SearchState> emit,
  ) async {
    final now = DateTime.now();

    final defaultQuery = ChartFilterQuery(
      startDate: event.startDate,
      endDate: now,
      furnaceNo: event.furnaceNo,
      materialNo: event.materialNo,
    );
    debugPrint('$defaultQuery');

    emit(SearchState(
      status: SearchStatus.initial,
      currentQuery: defaultQuery,
      errorMessage: '',
      // reset dropdowns to defaults
      furnaceOptions: const ["0"],
      materialOptions: const ["All Material No."],
      optionsLoading: false,
      optionsError: null,
    ));
    // Optionally trigger reload of options here:
    add(const LoadDropdownOptions());
  }

  Future<void> _onUpdateDateRange(
    UpdateDateRange event,
    Emitter<SearchState> emit,
  ) async {
    print('🔄 SearchBloc received UpdateDateRange');
    print('Start: ${event.startDate}');
    print('End: ${event.endDate}');

    await _updateQueryAndFetch(
      emit,
      state.currentQuery.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    // Refresh dropdowns after date change (if API depends on filters/time window)
    add(const LoadDropdownOptions());
  }

  // 🔥 Helper to reduce duplication
  Future<void> _updateQueryAndFetch(
    Emitter<SearchState> emit,
    ChartFilterQuery newQuery,
  ) async {
    emit(state.copyWith(status: () => SearchStatus.loading));
    try {
      print('📋 Updated query: $newQuery');
      print('Query params: ${newQuery.toQueryParams()}');

      final results = await Future.wait([
        _searchApiService.getFilteringChartDetails(newQuery),
        _searchApiService.getControlChartStat(newQuery),
      ]);

      final chartDetails = results[0] as List<ChartDetail>;
      final chartStatistics = results[1] as ControlChartStats;

      print('✅ API call successful, emitting success state $chartStatistics');

      emit(state.copyWith(
        status: () => SearchStatus.success,
        chartDetails: () => chartDetails,
        controlChartStats: () => chartStatistics,
        currentQuery: () => newQuery,
        errorMessage: () => null,
      ));
    } catch (e) {
      print('❌ API call failed: $e');

      emit(state.copyWith(
        status: () => SearchStatus.failure,
        errorMessage: () => e.toString(),
        currentQuery: () => newQuery, // Keep new query even on error
      ));
    }
  }

  // ---------------- dropdown helpers & handlers (NEW) ----------------

  // Normalize “All” between UI ↔ Query ↔ API
  String? _normFurnaceForApi(String? v) =>
      (v == null || v.isEmpty || v == '0') ? null : v;

  String? _normCpForApi(String? v) =>
      (v == null || v.isEmpty || v == 'All Material No.') ? null : v;

  // Fetch options from SettingApis and return sorted lists with “All” items
  Future<({List<String> furnaces, List<String> materials})> _fetchDropdowns({
    String? furnaceNo,
    String? materialNo,
  }) async {
    final json = await _settingApis.getSettingFormDropdown(
      furnaceNo: _normFurnaceForApi(furnaceNo),
      cpNo: _normCpForApi(materialNo),
    );

    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    List<String> toStringList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List) {
        return v.map((e) => e?.toString()).whereType<String>().toList();
      }
      return <String>[v.toString()];
    }

    final furnaces = toStringList(payload['furnaceNo'])..sort();
    final cps = toStringList(payload['cpNo'])..sort();

    return (
      furnaces: ['0', ...furnaces], // "0" = All
      materials: ['All Material No.', ...cps],
    );
  }

  // Ensure current selections are present in the lists (so dropdowns can show them)
  ({List<String> furnaces, List<String> materials}) _ensureSelectedPresent(
    List<String> furnaces,
    List<String> materials, {
    String? furnaceSel,
    String? materialSel,
  }) {
    final f = List<String>.from(furnaces);
    final m = List<String>.from(materials);

    if (furnaceSel != null && furnaceSel.isNotEmpty && !f.contains(furnaceSel)) {
      f.add(furnaceSel);
    }
    if (materialSel != null &&
        materialSel.isNotEmpty &&
        materialSel != 'All Material No.' &&
        !m.contains(materialSel)) {
      m.add(materialSel);
    }
    return (furnaces: f, materials: m);
  }

  // Load dropdown options (call on init / date change / after selection)
  Future<void> _onLoadDropdownOptions(
    LoadDropdownOptions event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(optionsLoading: () => true, optionsError: () => null));
    try {
      final furnaceUi = event.furnaceNo ?? state.currentQuery.furnaceNo;
      final materialUi = event.materialNo ?? state.currentQuery.materialNo;

      final res = await _fetchDropdowns(
        furnaceNo: furnaceUi,
        materialNo: materialUi,
      );

      final added = _ensureSelectedPresent(
        res.furnaces,
        res.materials,
        furnaceSel: (furnaceUi == null || furnaceUi.isEmpty) ? '0' : furnaceUi,
        materialSel: (materialUi == null || materialUi.isEmpty)
            ? 'All Material No.'
            : materialUi,
      );

      emit(state.copyWith(
        optionsLoading: () => false,
        furnaceOptions: () => added.furnaces..sort((a, b) {
          // keep "0" first
          if (a == '0') return -1;
          if (b == '0') return 1;
          return a.compareTo(b);
        }),
        materialOptions: () => added.materials..sort((a, b) {
          // keep "All Material No." first
          if (a == 'All Material No.') return -1;
          if (b == 'All Material No.') return 1;
          return a.compareTo(b);
        }),
        optionsError: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        optionsLoading: () => false,
        optionsError: () => e.toString(),
      ));
    }
  }

  // User selected furnace
  Future<void> _onSelectFurnace(
    SelectFurnace event,
    Emitter<SearchState> emit,
  ) async {
    final normalizedForQuery = (event.furnaceNo == '0') ? '' : event.furnaceNo;

    final newQuery = state.currentQuery.copyWith(
      furnaceNo: normalizedForQuery,
    );

    // 1) Reload charts for the new selection
    await _updateQueryAndFetch(emit, newQuery);

    // 2) Refresh options (filtered by new selection)
    add(LoadDropdownOptions(
      furnaceNo: event.furnaceNo, // UI value ("0" allowed)
      materialNo: state.currentMaterialUiValue,
    ));
  }

  // User selected material
  Future<void> _onSelectMaterial(
    SelectMaterial event,
    Emitter<SearchState> emit,
  ) async {
    final normalizedForQuery =
        (event.materialNo == 'All Material No.') ? '' : event.materialNo;

    final newQuery = state.currentQuery.copyWith(
      materialNo: normalizedForQuery,
    );

    // 1) Reload charts
    await _updateQueryAndFetch(emit, newQuery);

    // 2) Refresh options (filtered by new selection)
    add(LoadDropdownOptions(
      furnaceNo: state.currentFurnaceUiValue, // "0" allowed
      materialNo: event.materialNo,           // UI value
    ));
  }
}