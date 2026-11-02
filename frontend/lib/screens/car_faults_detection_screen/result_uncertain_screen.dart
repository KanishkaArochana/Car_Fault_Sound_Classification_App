import 'package:flutter/material.dart';
import '../../models/fault_result.dart';
import '../../services/history_storage_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/result_banner.dart';
import '../../widgets/confidence_ring.dart';
import '../../widgets/recommendation_list.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/gray_button.dart';
import 'recording_screen.dart';
import 'solution_details_screen.dart';

class ResultUncertainScreen extends StatefulWidget {
  final FaultResult result;

  const ResultUncertainScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultUncertainScreen> createState() => _ResultUncertainScreenState();
}

class _ResultUncertainScreenState extends State<ResultUncertainScreen> {
  final HistoryStorageService _historyService = HistoryStorageService();

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  void _saveToHistory() async {
    await _historyService.saveResult(widget.result);
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              // Main content card matching design layout
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
                      // Uncertain Status Banner
                      ResultBanner(
                        title: ResultStrings.uncertainResult,
                        iconPath: 'assets/icons/uncertain.svg',
                        backgroundColor: const Color(0xFFFEF3C7),
                        contentColor: AppColors.warningOrange,
                      ),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Diagnostic Output Text
                              const Text(
                                'Unable to identify the fault\nwith high confidence.',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                              
                              const SizedBox(height: 24.0),
                              
                              // Confidence Level Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Confidence Level',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  ConfidenceRing(
                                    confidence: widget.result.confidence,
                                    progressColor: AppColors.warningOrange,
                                    size: 88,
                                    strokeWidth: 7.0,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20.0),
                              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                              const SizedBox(height: 16.0),
                              
                              // Possible Reasons Alert Box (Soft Yellow/Orange tint)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: const Color(0xFFFEF3C7),
                                    width: 1.0,
                                  ),
                                ),
                                child: RecommendationList(
                                  title: 'Possible reasons:',
                                  recommendations: widget.result.recommendations,
                                  firstLetterColor: AppColors.textPrimary,
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

              // Bottom Action Buttons
              PrimaryButton(
                text: ResultStrings.tryAgain,
                iconPath: 'assets/icons/retry.svg',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const RecordingScreen(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12.0),
              
              GrayButton(
                text: ResultStrings.viewTips,
                iconPath: 'assets/icons/about.svg',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SolutionDetailsScreen(
                        faultName: widget.result.faultName,
                      ),
                    ),
                  );
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
