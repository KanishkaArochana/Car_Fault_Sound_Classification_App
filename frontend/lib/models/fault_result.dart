class FaultResult {
  final String faultName;
  final double confidence;
  final DateTime timestamp;
  final List<String> recommendations;

  FaultResult({
    required this.faultName,
    required this.confidence,
    required this.timestamp,
    required this.recommendations,
  });

  factory FaultResult.fromJson(Map<String, dynamic> json) => FaultResult(
        faultName: json['fault_name'],
        confidence: (json['confidence'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
        recommendations: List<String>.from(json['recommendations'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'fault_name': faultName,
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
        'recommendations': recommendations,
      };
}
