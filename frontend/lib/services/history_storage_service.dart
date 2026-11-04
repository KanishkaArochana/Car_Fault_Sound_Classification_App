import 'dart:async';
import '../models/fault_result.dart';

/// Service responsible for managing local history records of diagnostic results.
class HistoryStorageService {
  // In-memory static store to keep diagnostic records active during the session
  static final List<FaultResult> _historyStore = [];
  static bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    // Prepopulate with realistic mockup diagnostic logs for premium visual presentation
    _historyStore.addAll([
      FaultResult(
        faultName: 'Bad Ignition',
        confidence: 0.94,
        timestamp: DateTime(2025, 5, 20, 10, 30),
        recommendations: [
          'Inspect spark plugs.',
          'Check ignition coil.',
          'Check ignition wires.',
          'Clear fault code and test again.',
        ],
      ),
      FaultResult(
        faultName: 'Low Oil',
        confidence: 0.78,
        timestamp: DateTime(2025, 5, 19, 18, 15),
        recommendations: [
          'Top up engine oil immediately.',
          'Check for visible oil leaks.',
        ],
      ),
      FaultResult(
        faultName: 'Normal Engine Idle',
        confidence: 0.92,
        timestamp: DateTime(2025, 5, 18, 9, 20),
        recommendations: [
          'Maintain standard maintenance schedule.',
          'Check fluids and spark plugs periodically.',
        ],
      ),
      FaultResult(
        faultName: 'Power Steering Belt',
        confidence: 0.70,
        timestamp: DateTime(2025, 5, 17, 16, 45),
        recommendations: [
          'Inspect power steering belt tension.',
          'Check for cracks or signs of wear.',
        ],
      ),
      FaultResult(
        faultName: 'Dead Battery',
        confidence: 0.95,
        timestamp: DateTime(2025, 5, 16, 11, 10),
        recommendations: [
          'Test battery voltage with a multimeter.',
          'Inspect battery terminal connections.',
        ],
      ),
    ]);
  }

  /// Saves a diagnostic classification result to history
  Future<void> saveResult(FaultResult result) async {
    _ensureInitialized();
    // Add result to beginning of list (newest first)
    _historyStore.insert(0, result);
    // Simulate minor storage I/O delay
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Retrieves all recorded diagnostic results
  Future<List<FaultResult>> getHistory() async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_historyStore);
  }

  /// Clears all recorded diagnostics from history
  Future<void> clearHistory() async {
    _ensureInitialized();
    _historyStore.clear();
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
