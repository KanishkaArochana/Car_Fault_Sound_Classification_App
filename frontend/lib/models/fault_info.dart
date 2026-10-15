class FaultInfo {
  final String faultName;
  final String iconAsset;
  final String aboutText;
  final List<String> checkItems;
  final List<String> todoSteps;

  const FaultInfo({
    required this.faultName,
    required this.iconAsset,
    required this.aboutText,
    required this.checkItems,
    required this.todoSteps,
  });
}
