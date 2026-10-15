import 'package:flutter/material.dart';
import '../../models/fault_result.dart';
import '../../models/ranked_fault_result.dart';
import '../../services/history_storage_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/result_banner.dart';
import '../../widgets/class_ranking_tile.dart';
import '../../widgets/recommendation_list.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/gray_button.dart';
import 'recording_screen.dart';
import 'solution_details_screen.dart';

/// Shows the outcome of a longer recording that was split into several
/// 5-second segments: every fault class that came up across those segments,
/// ordered from most frequent to least, each with its average confidence.
class ResultRankedScreen extends StatefulWidget {
  final RankedFaultResult result;

  const ResultRankedScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultRankedScreen> createState() => _ResultRankedScreenState();
}

class _ResultRankedScreenState extends State<ResultRankedScreen> {
  final HistoryStorageService _historyService = HistoryStorageService();

  @override
  void initState() {
    super.initState();
    _saveTopResultToHistory();
  }

  void _saveTopResultToHistory() async {
    final top = widget.result.topResult;
    await _historyService.saveResult(
      FaultResult(
        faultName: top.faultName,
        confidence: top.averageConfidence,
        timestamp: widget.result.timestamp,
        recommendations: top.recommendations,
      ),
    );
  }

  bool get _topIsNormal {
    final name = widget.result.topResult.faultName.toLowerCase();
    return name.contains('normal') || name.contains('healthy');
  }

  @override
  Widget build(BuildContext context) {
    final top = widget.result.topResult;

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
                      ResultBanner(
                        title: _topIsNormal
                            ? ResultStrings.healthyDetected
                            : ResultStrings.faultDetected,
                        iconPath: _topIsNormal
                            ? 'assets/icons/ok.svg'
                            : 'assets/icons/fault.svg',
                        backgroundColor: _topIsNormal
                            ? const Color(0xFFE6F4EA)
                            : const Color(0xFFFEE2E2),
                        contentColor: _topIsNormal
                            ? AppColors.successGreen
                            : AppColors.faultRed,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analyzed ${widget.result.totalChunks} '
                                'five-second segments from your recording.',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              const Text(
                                'Detected classes, most frequent first',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              // Ranked list — one tile per distinct class.
                              ...List.generate(widget.result.rankings.length,
                                  (index) {
                                final ranking = widget.result.rankings[index];
                                return ClassRankingTile(
                                  rank: index + 1,
                                  ranking: ranking,
                                  isTop: index == 0,
                                );
                              }),
                              const SizedBox(height: 8.0),
                              const Divider(
                                  color: Color(0xFFF1F5F9), thickness: 1.5),
                              const SizedBox(height: 16.0),
                              // Recommendations for the top (most frequent) class.
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: _topIsNormal
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: _topIsNormal
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFEE2E2),
                                    width: 1.0,
                                  ),
                                ),
                                child: RecommendationList(
                                  title: 'Recommended for ${top.faultName}:',
                                  recommendations: top.recommendations,
                                  firstLetterColor: _topIsNormal
                                      ? AppColors.successGreen
                                      : AppColors.faultRed,
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
                        faultName: top.faultName,
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
