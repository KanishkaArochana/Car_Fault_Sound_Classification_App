import '../models/fault_info.dart';

class FaultKnowledgeBase {
  FaultKnowledgeBase._();

  static const Map<String, FaultInfo> _knowledgeMap = {
    'Bad Ignition': FaultInfo(
      faultName: 'Bad Ignition',
      iconAsset: 'assets/icons/red_engine.svg',
      aboutText: 'Bad ignition occurs when the spark plug, ignition coil or related components fail to deliver proper spark to the engine.',
      checkItems: [
        'Spark plugs condition',
        'Ignition coil',
        'Ignition wires',
        'Fuel quality',
      ],
      todoSteps: [
        'Replace damaged spark plugs.',
        'Check and replace ignition coil if needed.',
        'Inspect wires for damage.',
        'Clear fault code and test again.',
      ],
    ),
    'Normal Engine Idle': FaultInfo(
      faultName: 'Normal Engine Idle',
      iconAsset: 'assets/icons/ok.svg',
      aboutText: 'The engine is operating normally at idle speeds with no anomalies detected.',
      checkItems: [
        'Engine RPM stability',
        'Fluid levels',
        'Belts visual wear',
      ],
      todoSteps: [
        'Perform scheduled routine service checks.',
        'Review diagnostic logs periodically.',
      ],
    ),
    'Inconclusive Analysis': FaultInfo(
      faultName: 'Inconclusive Analysis',
      iconAsset: 'assets/icons/uncertain.svg',
      aboutText: 'The acoustic analyzer could not establish a classification match with high confidence.',
      checkItems: [
        'Background noise level',
        'Recording duration',
        'Microphone proximity to engine block',
      ],
      todoSteps: [
        'Move the vehicle to a quieter location away from road traffic.',
        'Hold the device microphone closer to the engine block.',
        'Ensure the recording duration is at least 3-5 seconds.',
      ],
    ),
  };

  /// Looks up fault information by its name. Falls back to Bad Ignition if not found.
  static FaultInfo getFaultInfo(String faultName) {
    return _knowledgeMap[faultName] ?? _knowledgeMap['Bad Ignition']!;
  }
}
