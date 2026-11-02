import '../models/fault_result.dart';

class HistoryEntry {
  final FaultResult result;

  const HistoryEntry({
    required this.result,
  });

  String get faultName => result.faultName;
  double get confidence => result.confidence;
  DateTime get timestamp => result.timestamp;
}
