// Prediction statistics for a single fault class across audio chunks
class ClassRanking {
  final String faultName; // Display name
  final String rawClassName; // Backend class name
  final int occurrences; // Detected chunk count
  final int totalChunks; // Total chunks analyzed
  final double averageConfidence; // 0.0 - 1.0 average confidence
  final List<String> recommendations; // Solution steps

  ClassRanking({
    required this.faultName,
    required this.rawClassName,
    required this.occurrences,
    required this.totalChunks,
    required this.averageConfidence,
    required this.recommendations,
  });

  // Fraction of chunks (0.0 - 1.0) for this class
  double get frequency => totalChunks == 0 ? 0.0 : occurrences / totalChunks;
}

// Aggregated ranked fault predictions for full recording
class RankedFaultResult {
  final List<ClassRanking> rankings; // Sorted by frequency & confidence
  final int totalChunks; // Total chunk count
  final DateTime timestamp; // Completion time

  RankedFaultResult({
    required this.rankings,
    required this.totalChunks,
    required this.timestamp,
  });

  // Top predicted fault
  ClassRanking get topResult => rankings.first;
}
