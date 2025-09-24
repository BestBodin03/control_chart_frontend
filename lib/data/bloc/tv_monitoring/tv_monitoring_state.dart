part of 'tv_monitoring_bloc.dart';

enum TvMonitoringStatus { initial, running, paused }

final class TvMonitoringState extends Equatable {
  const TvMonitoringState({
    this.status = TvMonitoringStatus.initial,
    this.profiles = const [],
    this.index = 0,
    this.errorMessage,
  });

  final TvMonitoringStatus status;
  final List<HomeContentVar> profiles;
  final int index;
  final String? errorMessage;

  // Computed
  bool get isInitial => status == TvMonitoringStatus.initial;
  bool get isRunning => status == TvMonitoringStatus.running;
  bool get hasProfiles => profiles.isNotEmpty;

  TvMonitoringState copyWith({
    TvMonitoringStatus Function()? status,
    List<HomeContentVar> Function()? profiles,
    int Function()? index,
    String? Function()? errorMessage,
  }) {
    return TvMonitoringState(
      status: status != null ? status() : this.status,
      profiles: profiles != null ? profiles() : this.profiles,
      index: index != null ? index() : this.index,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profiles, index, errorMessage];
}
