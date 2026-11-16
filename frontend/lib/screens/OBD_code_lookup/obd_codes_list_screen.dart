import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_search_bar.dart';
import 'obd_code_details_screen.dart';

class ObdCodesListScreen extends StatefulWidget {
  final String categoryName;
  final String jsonFileName;

  const ObdCodesListScreen({
    super.key,
    required this.categoryName,
    required this.jsonFileName,
  });

  @override
  State<ObdCodesListScreen> createState() => _ObdCodesListScreenState();
}

class _ObdCodesListScreenState extends State<ObdCodesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _codes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    try {
      final jsonStr = await rootBundle.loadString('lib/screens/OBD_code_lookup/${widget.jsonFileName}');
      final List<dynamic> decodedList = json.decode(jsonStr);
      setState(() {
        _codes = decodedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading codes: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getAppBarTitle() {
    String prefix = 'P';
    if (widget.categoryName.toLowerCase() == 'body') {
      prefix = 'B';
    } else if (widget.categoryName.toLowerCase() == 'chassis') {
      prefix = 'C';
    } else if (widget.categoryName.toLowerCase() == 'network') {
      prefix = 'U';
    }
    return '$prefix - ${widget.categoryName} Codes';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );
    }

    final filteredCodes = _codes.where((item) {
      final code = (item['code'] as String? ?? '').toLowerCase();
      final title = (item['title'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return code.contains(query) || title.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search code e.g. P0301',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),
          
          // Codes list
          Expanded(
            child: filteredCodes.isEmpty
                ? const Center(
                    child: Text(
                      'No codes found matching your search.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.0,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: filteredCodes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                    itemBuilder: (context, index) {
                      final item = filteredCodes[index];
                      final code = item['code'] as String? ?? '';
                      final title = item['title'] as String? ?? '';
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x02000000),
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ObdCodeDetailsScreen(codeData: item),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          code,
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13.0,
                                            color: AppColors.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppColors.textSecondary,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
