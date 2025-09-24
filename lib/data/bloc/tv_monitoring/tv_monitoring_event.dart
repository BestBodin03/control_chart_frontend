part of 'tv_monitoring_bloc.dart';

sealed class TvMonitoringEvent extends Equatable {
  const TvMonitoringEvent();

  @override
  List<Object?> get props => [];
}

final class TvProfilesUpdated extends TvMonitoringEvent {
  final List<HomeContentVar> profiles;
  const TvProfilesUpdated(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

final class TvPageChanged extends TvMonitoringEvent {
  final int index;
  const TvPageChanged(this.index);

  @override
  List<Object?> get props => [index];
}

final class TvTimerTicked extends TvMonitoringEvent {
  const TvTimerTicked();
}
