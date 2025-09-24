import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';

part 'tv_monitoring_event.dart';
part 'tv_monitoring_state.dart';

class TvMonitoringBloc extends Bloc<TvMonitoringEvent, TvMonitoringState> {
  Timer? _timer;

  TvMonitoringBloc() : super(const TvMonitoringState()) {
    on<TvProfilesUpdated>(_onProfilesUpdated);
    on<TvPageChanged>(_onPageChanged);
    on<TvTimerTicked>(_onTimerTicked);
  }

  void _onProfilesUpdated(
    TvProfilesUpdated e,
    Emitter<TvMonitoringState> emit,
  ) {
    _timer?.cancel();
    if (e.profiles.isEmpty) {
      emit(const TvMonitoringState());
      return;
    }

    _dispatchQuery(e.profiles.first);
    _startTimer(0, e.profiles);

    emit(state.copyWith(
      profiles: () => e.profiles,
      index: () => 0,
    ));
  }

  void _onPageChanged(
    TvPageChanged e,
    Emitter<TvMonitoringState> emit,
  ) {
    _timer?.cancel();
    final i = e.index;
    if (i < 0 || i >= state.profiles.length) return;

    _dispatchQuery(state.profiles[i]);
    _startTimer(i, state.profiles);

    emit(state.copyWith(index: () => i));
  }

  void _onTimerTicked(
    TvTimerTicked e,
    Emitter<TvMonitoringState> emit,
  ) {
    if (state.profiles.isEmpty) return;
    final next = (state.index + 1) % state.profiles.length;
    add(TvPageChanged(next));
  }

  // ----------------- helpers -----------------
  void _dispatchQuery(HomeContentVar p) {
    // TODO: connect to SearchBloc
    // context.read<SearchBloc>().add(LoadFilteredChartData(...));
  }

  void _startTimer(int i, List<HomeContentVar> profiles) {
    final sec = profiles[i].interval.clamp(1, 600).toInt();
    _timer = Timer.periodic(Duration(seconds: sec), (_) => add(TvTimerTicked()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
