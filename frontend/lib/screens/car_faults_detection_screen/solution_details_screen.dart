import 'package:flutter/material.dart';
import '../../data/fault_knowledge_base.dart';
import '../../constants/app_colors.dart';
import '../../models/fault_result.dart';
import '../../services/history_storage_service.dart';
import '../../widgets/fault_header_card.dart';
import '../../widgets/check_item_tile.dart';
import '../../widgets/solution_step_tile.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/gray_button.dart';

class SolutionDetailsScreen extends StatelessWidget {
  final String faultName;

  const SolutionDetailsScreen({
    super.key,
    required this.faultName,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Look up FaultInfo in knowledge base
    final faultInfo = FaultKnowledgeBase.getFaultInfo(faultName);
    final historyService = HistoryStorageService();

    // 2. Select theme colors based on the type of fault
    Color headerBg;
    Color headerText;

    if (faultName.toLowerCase().contains('normal') || 
        faultName.toLowerCase().contains('healthy')) {
      headerBg = const Color(0xFFE8F5E9);
      headerText = AppColors.successGreen;
    } else if (faultName.toLowerCase().contains('inconclusive') || 
               faultName.toLowerCase().contains('uncertain')) {
      headerBg = const Color(0xFFFEF3C7);
      headerText = AppColors.warningOrange;
    } else {
      headerBg = const Color(0xFFFEE2E2);
      headerText = AppColors.faultRed;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 26,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Solution Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              // Main content card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Fault Header Card
                      FaultHeaderCard(
                        faultName: faultInfo.faultName,
                        iconAsset: faultInfo.iconAsset,
                        backgroundColor: headerBg,
                        contentColor: headerText,
                      ),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 2. About This Fault
                              const Text(
                                'About This Fault',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                faultInfo.aboutText,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              
                              const SizedBox(height: 20.0),
                              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                              const SizedBox(height: 16.0),
                              
                              // 3. What To Check
                              const Text(
                                'What To Check',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              ...faultInfo.checkItems.map(
                                (item) => CheckItemTile(checkItem: item),
                              ),
                              
                              const SizedBox(height: 20.0),
                              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                              const SizedBox(height: 16.0),
                              
                              // 4. What To Do
                              const Text(
                                'What To Do',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              ...List.generate(
                                faultInfo.todoSteps.length,
                                (index) => SolutionStepTile(
                                  stepNumber: index + 1,
                                  stepText: faultInfo.todoSteps[index],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Bottom Action Buttons: Save History and Cancel
              PrimaryButton(
                text: 'Save History',
                iconPath: 'assets/icons/save.svg',
                onPressed: () async {
                  // Construct a result to save to History
                  final result = FaultResult(
                    faultName: faultInfo.faultName,
                    confidence: 0.95,
                    timestamp: DateTime.now(),
                    recommendations: faultInfo.checkItems,
                  );
                  await historyService.saveResult(result);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diagnostic saved to History successfully!'),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),

              const SizedBox(height: 12.0),

              GrayButton(
                text: 'Cancel',
                iconPath: 'assets/icons/about.svg',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
