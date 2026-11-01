class FaultSolution {
  final String faultName;
  final List<String> recommendations;
  final List<String> detailedSteps;

  const FaultSolution({
    required this.faultName,
    required this.recommendations,
    required this.detailedSteps,
  });
}

class FaultSolutionsData {
  FaultSolutionsData._();

  static const Map<String, FaultSolution> _solutions = {
    'Bad Ignition': FaultSolution(
      faultName: 'Bad Ignition',
      recommendations: [
        'Inspect spark plugs.',
        'Check ignition coil.',
        'Check ignition wires.',
        'Clear fault code and test again.',
      ],
      detailedSteps: [
        'Check ignition coil resistance using a multimeter.',
        'Inspect spark plugs for carbon buildup, oil fouling, or physical damage.',
        'Verify ignition wire continuity and visual wear.',
        'Clear fault codes from OBD-II memory and perform a test drive.',
      ],
    ),
    'Engine Knocking Detected': FaultSolution(
      faultName: 'Engine Knocking Detected',
      recommendations: [
        'Inspect spark plugs and ignition timing',
        'Check engine oil levels and fuel octane level',
        'Consult a certified mechanic for a detailed diagnostic scan',
      ],
      detailedSteps: [
        'Check spark plugs for overheating deposits or physical wear.',
        'Verify current engine oil level and pressure.',
        'Refuel with higher octane gasoline to prevent pre-ignition.',
        'Connect an OBD scanner to check knock sensor output signals.',
      ],
    ),
    'Normal Engine Idle': FaultSolution(
      faultName: 'Normal Engine Idle',
      recommendations: [
        'Maintain standard maintenance schedule.',
        'Check fluids and spark plugs periodically.',
      ],
      detailedSteps: [
        'Perform standard engine oil changes as scheduled.',
        'Inspect cooling system levels and hoses.',
        'Verify engine air filter cleanliness.',
      ],
    ),
    'Low Oil': FaultSolution(
      faultName: 'Low Oil',
      recommendations: [
        'Top up engine oil immediately.',
        'Check for visible oil leaks.',
      ],
      detailedSteps: [
        'Locate the engine oil dipstick, wipe clean, and measure current levels.',
        'Refill with the recommended oil grade to the max indicator line.',
        'Inspect oil pan gasket and filter seals for leaks.',
      ],
    ),
    'Power Steering Belt': FaultSolution(
      faultName: 'Power Steering Belt',
      recommendations: [
        'Inspect power steering belt tension.',
        'Check for cracks or signs of wear.',
      ],
      detailedSteps: [
        'Locate the power steering pump drive belt in the engine bay.',
        'Check belt deflection/tension by applying moderate pressure.',
        'Inspect the belt ribs for cracks, fraying, or glazing.',
      ],
    ),
    'Dead Battery': FaultSolution(
      faultName: 'Dead Battery',
      recommendations: [
        'Test battery voltage with a multimeter.',
        'Inspect battery terminal connections.',
      ],
      detailedSteps: [
        'Connect a multimeter to measure resting battery voltage (should be ~12.6V).',
        'Check for corrosion at terminals and tighten the clamps.',
        'Perform a load test to determine if battery cell replacement is needed.',
      ],
    ),
    'Worn Out Brakes': FaultSolution(
      faultName: 'Worn Out Brakes',
      recommendations: [
        'Inspect brake pad thickness.',
        'Check rotors for scoring or warping.',
        'Have brakes serviced soon.',
      ],
      detailedSteps: [
        'Measure remaining brake pad thickness through the wheel spokes or by removing the wheel.',
        'Inspect rotor surface for deep grooves, scoring, or discoloration from overheating.',
        'Listen for squealing (wear indicator) or grinding (metal-on-metal) sounds while braking.',
        'Schedule a brake service appointment if pad thickness is below 3mm.',
      ],
    ),
    'Normal Brakes': FaultSolution(
      faultName: 'Normal Brakes',
      recommendations: [
        'No action needed \u2014 brakes sound healthy.',
        'Continue routine brake inspections.',
      ],
      detailedSteps: [
        'Maintain your regular brake pad and rotor inspection schedule.',
        'Top up brake fluid if due for a change.',
      ],
    ),
    'Normal Engine Startup': FaultSolution(
      faultName: 'Normal Engine Startup',
      recommendations: [
        'No action needed \u2014 startup sounds healthy.',
        'Continue standard maintenance schedule.',
      ],
      detailedSteps: [
        'Keep up with scheduled oil changes and battery checks.',
        'Monitor for any change in startup sound over time.',
      ],
    ),
    'Power Steering': FaultSolution(
      faultName: 'Power Steering',
      recommendations: [
        'Check power steering fluid level.',
        'Inspect for leaks around the pump and hoses.',
        'Listen for whining noise while turning the wheel.',
      ],
      detailedSteps: [
        'Locate the power steering fluid reservoir and check the level against the min/max markers.',
        'Inspect hoses and the pump housing for visible fluid leaks.',
        'Turn the steering wheel lock-to-lock while parked and listen for whining or groaning.',
      ],
    ),
    'Serpentine Belt': FaultSolution(
      faultName: 'Serpentine Belt',
      recommendations: [
        'Inspect serpentine belt for cracks or glazing.',
        'Check belt tensioner and pulleys.',
      ],
      detailedSteps: [
        'Visually inspect the full length of the serpentine belt for cracks, fraying, or glazing.',
        'Check the automatic tensioner for proper spring tension and free rotation.',
        'Inspect pulleys for wobble or unusual noise while the engine runs.',
      ],
    ),
    'No Oil and Serpentine Belt Issue': FaultSolution(
      faultName: 'No Oil and Serpentine Belt Issue',
      recommendations: [
        'Check and top up engine oil immediately.',
        'Inspect serpentine belt for wear or looseness.',
        'Address both issues before continued driving.',
      ],
      detailedSteps: [
        'Check oil level via the dipstick and refill to the correct level.',
        'Inspect the serpentine belt for cracking, glazing, or slipping.',
        'Have both systems checked together, as low oil can accelerate belt-driven component wear.',
      ],
    ),
    'Power Steering and Low Oil Issue': FaultSolution(
      faultName: 'Power Steering and Low Oil Issue',
      recommendations: [
        'Check engine oil level and top up if needed.',
        'Check power steering fluid level.',
        'Have both systems inspected together.',
      ],
      detailedSteps: [
        'Check engine oil level via the dipstick and refill as needed.',
        'Check power steering fluid reservoir level and inspect for leaks.',
        'Get a combined inspection, as both issues appearing together may point to a shared root cause.',
      ],
    ),
    'Power Steering, Low Oil, and Serpentine Belt Issue': FaultSolution(
      faultName: 'Power Steering, Low Oil, and Serpentine Belt Issue',
      recommendations: [
        'Multiple issues detected \u2014 seek professional inspection soon.',
        'Check oil, power steering fluid, and serpentine belt condition.',
      ],
      detailedSteps: [
        'Check engine oil level and power steering fluid level; top up if low.',
        'Inspect the serpentine belt for wear, since it drives both the oil pump accessories and power steering pump.',
        'Given multiple simultaneous symptoms, schedule a full mechanic inspection rather than DIY diagnosis.',
      ],
    ),
    'Power Steering and Serpentine Belt Issue': FaultSolution(
      faultName: 'Power Steering and Serpentine Belt Issue',
      recommendations: [
        'Check power steering fluid level.',
        'Inspect serpentine belt condition and tension.',
      ],
      detailedSteps: [
        'Check the power steering fluid reservoir and inspect hoses/pump for leaks.',
        'Inspect the serpentine belt for cracking, glazing, or improper tension, since it drives the power steering pump.',
      ],
    ),
    'Inconclusive Analysis': FaultSolution(
      faultName: 'Inconclusive Analysis',
      recommendations: [
        'Record in a quieter place.',
        'Ensure device mic is near the engine block.',
      ],
      detailedSteps: [
        'Relocate the vehicle to a quiet, sheltered garage or area away from road noise.',
        'Hold the device microphone within 1-2 feet of the engine block.',
        'Verify that the microphone is not covered by hands or phone cases.',
      ],
    ),
  };

  // Retrieves solution recommendations and detailed steps for a specific fault.
  static FaultSolution getSolutionForFault(String faultName) {
    return _solutions[faultName] ?? _solutions['Bad Ignition']!;
  }
}
