/// How often a single fault class was predicted across the 5-second chunks
/// of a longer recording, plus its average confidence across those chunks.
class ClassRanking {
  final String faultName; // display name, e.g. "Bad Ignition"
  final String rawClassName; // backend class name, e.g. "bad_ignition"
  final int occurrences;
  final int totalChunks;
  final double averageConfidence; // 0.0 - 1.0, averaged over occurrences
  final List<String> recommendations;

  ClassRanking({
    required this.faultName,
    required this.rawClassName,
    required this.occurrences,
    required this.totalChunks,
    required this.averageConfidence,
    required this.recommendations,
  });

  /// Fraction of chunks (0.0 - 1.0) that were classified as this class.
  double get frequency => totalChunks == 0 ? 0.0 : occurrences / totalChunks;
}

/// Aggregated result of classifying a longer recording that was split into
/// several 5-second chunks: a ranked list of classes, most-frequent first.
class RankedFaultResult {
  /// Sorted most-frequent-first (ties broken by higher average confidence).
  final List<ClassRanking> rankings;
  final int totalChunks;
  final DateTime timestamp;

  RankedFaultResult({
    required this.rankings,
    required this.totalChunks,
    required this.timestamp,
  });

  ClassRanking get topResult => rankings.first;
}
