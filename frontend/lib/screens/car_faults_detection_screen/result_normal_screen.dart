import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/fault_result.dart';
import '../../services/history_storage_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/result_banner.dart';
import '../../widgets/confidence_ring.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/gray_button.dart';
import 'recording_screen.dart';
import 'solution_details_screen.dart';

class ResultNormalScreen extends StatefulWidget {
  final FaultResult result;

  const ResultNormalScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultNormalScreen> createState() => _ResultNormalScreenState();
}

class _ResultNormalScreenState extends State<ResultNormalScreen> {
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
                      // Status Banner
                      ResultBanner(
                        title: ResultStrings.noFaultDetected,
                        iconPath: 'assets/icons/ok.svg',
                        backgroundColor: const Color(0xFFE8F5E9),
                        contentColor: AppColors.successGreen,
                      ),
                      
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Engine Status Title Section
                              const Text(
                                'Engine Status',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                widget.result.faultName,
                                style: const TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.successGreen,
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
                                    progressColor: AppColors.successGreen,
                                    size: 88,
                                    strokeWidth: 7.0,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20.0),
                              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                              const SizedBox(height: 20.0),
                              
                              // Info Alert Box Card (Green)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: const Color(0xFFC8E6C9),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/ok.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(width: 14.0),
                                    const Expanded(
                                      child: Text(
                                        'Your engine sound is normal.\nNo issues detected.',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2E7D32),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
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
                text: ResultStrings.recordAgain,
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
                text: ResultStrings.viewDetails,
                iconPath: 'assets/icons/view.svg',
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
