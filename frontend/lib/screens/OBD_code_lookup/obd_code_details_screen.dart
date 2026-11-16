import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ObdCodeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> codeData;

  const ObdCodeDetailsScreen({super.key, required this.codeData});

  @override
  State<ObdCodeDetailsScreen> createState() => _ObdCodeDetailsScreenState();
}

class _ObdCodeDetailsScreenState extends State<ObdCodeDetailsScreen> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? 'Code ${widget.codeData['code']} added to bookmarks'
              : 'Code ${widget.codeData['code']} removed from bookmarks',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.codeData['code'] as String? ?? 'N/A';
    final title = widget.codeData['title'] as String? ?? 'No Title';
    final description = widget.codeData['description'] as String? ?? 'No description available.';
    final possibleCauses = widget.codeData['possibleCauses'] as List<dynamic>? ?? [];
    final solutions = widget.codeData['solutions'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Code Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code Highlight Box (White Box)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFBFB),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.faultRed,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Description Section
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Possible Causes Section
                    if (possibleCauses.isNotEmpty) ...[
                      const Text(
                        'Possible Causes',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ...possibleCauses.map((cause) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    cause.toString(),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 24.0),
                    ],

                    // Solutions Section
                    if (solutions.isNotEmpty) ...[
                      const Text(
                        'Solution / Instructions',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ...List.generate(
                        solutions.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  solutions[index].toString(),
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bookmark Button at Bottom
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _toggleBookmark,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBookmarked ? const Color(0xFFE2E8F0) : AppColors.primaryBlue,
                      foregroundColor: _isBookmarked ? AppColors.textPrimary : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          _isBookmarked ? 'Bookmarked' : 'Bookmark',
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
