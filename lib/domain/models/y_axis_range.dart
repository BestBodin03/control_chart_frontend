class YAxisRange {
  final double? maxYsurfaceHardnessControlChart;
  final double? minYsurfaceHardnessControlChart;
  final double? maxYsurfaceHardnessMrChart;

  final double? maxYcompoundLayerControlChart;
  final double? minYcompoundLayerControlChart;
  final double? maxYcompoundLayerMrChart;

  final double? maxYcdeControlChart;
  final double? minYcdeControlChart;
  final double? maxYcdeMrChart;

  final double? maxYcdtControlChart;
  final double? minYcdtControlChart;
  final double? maxYcdtMrChart;

  const YAxisRange({
    this.maxYsurfaceHardnessControlChart,
    this.minYsurfaceHardnessControlChart,
    this.maxYsurfaceHardnessMrChart,

    this.maxYcompoundLayerControlChart,
    this.minYcompoundLayerControlChart,
    this.maxYcompoundLayerMrChart,

    this.maxYcdeControlChart,
    this.minYcdeControlChart,
    this.maxYcdeMrChart,

    this.maxYcdtControlChart,
    this.minYcdtControlChart,
    this.maxYcdtMrChart,
  });

  /// From JSON (if you’re mapping from your backend)
  factory YAxisRange.fromJson(Map<String, dynamic> json) {
    return YAxisRange(
      maxYsurfaceHardnessControlChart: (json['maxYsurfaceHardnessControlChart'] as num?)?.toDouble(),
      minYsurfaceHardnessControlChart: (json['minYsurfaceHardnessControlChart'] as num?)?.toDouble(),
      maxYsurfaceHardnessMrChart: (json['maxYsurfaceHardnessMrChart'] as num?)?.toDouble(),

      maxYcompoundLayerControlChart: (json['maxYcompoundLayerControlChart'] as num?)?.toDouble(),
      minYcompoundLayerControlChart: (json['minYcompoundLayerControlChart'] as num?)?.toDouble(),
      maxYcompoundLayerMrChart: (json['maxYcompoundLayerMrChart'] as num?)?.toDouble(),

      maxYcdeControlChart: (json['maxYcdeControlChart'] as num?)?.toDouble(),
      minYcdeControlChart: (json['minYcdeControlChart'] as num?)?.toDouble(),
      maxYcdeMrChart: (json['maxYcdeMrChart'] as num?)?.toDouble(),

      maxYcdtControlChart: (json['maxYcdtControlChart'] as num?)?.toDouble(),
      minYcdtControlChart: (json['minYcdtControlChart'] as num?)?.toDouble(),
      maxYcdtMrChart: (json['maxYcdtMrChart'] as num?)?.toDouble(),
    );
  }

  /// To JSON (for sending back to backend if needed)
  Map<String, dynamic> toJson() {
    return {
      'maxYsurfaceHardnessControlChart': maxYsurfaceHardnessControlChart,
      'minYsurfaceHardnessControlChart': minYsurfaceHardnessControlChart,
      'maxYsurfaceHardnessMrChart': maxYsurfaceHardnessMrChart,

      'maxYcompoundLayerControlChart': maxYcompoundLayerControlChart,
      'minYcompoundLayerControlChart': minYcompoundLayerControlChart,
      'maxYcompoundLayerMrChart': maxYcompoundLayerMrChart,

      'maxYcdeControlChart': maxYcdeControlChart,
      'minYcdeControlChart': minYcdeControlChart,
      'maxYcdeMrChart': maxYcdeMrChart,

      'maxYcdtControlChart': maxYcdtControlChart,
      'minYcdtControlChart': minYcdtControlChart,
      'maxYcdtMrChart': maxYcdtMrChart,
    };
  }
}
