import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'data_importing.g.dart';

@JsonSerializable()
class DataImporting extends Equatable {
  final String jobId;
  final String status; // running, done, error
  @JsonKey(name: 'startedAt')
  final int? startedAt;
  @JsonKey(name: 'finishedAt')
  final int? finishedAt;
  final int total;
  final int completed;
  final int success;
  final int failed;
  final int percent;
  @JsonKey(name: 'lastItem')
  final String? lastItem;
  final List<String> errors;

  const DataImporting({
    required this.jobId,
    required this.status,
    this.startedAt,
    this.finishedAt,
    required this.total,
    required this.completed,
    required this.success,
    required this.failed,
    required this.percent,
    this.lastItem,
    required this.errors,
  });

  factory DataImporting.fromJson(Map<String, dynamic> json) => _$DataImportingFromJson(json);
  Map<String, dynamic> toJson() => _$DataImportingToJson(this);

  bool get isRunning => status == 'running';
  bool get isDone => status == 'done';
  bool get hasError => status == 'error' || errors.isNotEmpty;
  bool get isInitial => status == 'initial' || status.isEmpty;

  @override
  List<Object?> get props => [
    jobId,
    status,
    startedAt,
    finishedAt,
    total,
    completed,
    success,
    failed,
    percent,
    lastItem,
    errors,
  ];
}