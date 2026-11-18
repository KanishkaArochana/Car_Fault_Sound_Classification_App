import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_search_bar.dart';

class DashboardSymbol {
  final String name;
  final String fileName;
  final String severity;
  final Color color;
  final String meaning;
  final String action;

  const DashboardSymbol({
    required this.name,
    required this.fileName,
    required this.severity,
    required this.color,
    required this.meaning,
    required this.action,
  });
}

class DashboardSymbolsScreen extends StatefulWidget {
  const DashboardSymbolsScreen({super.key});

  @override
  State<DashboardSymbolsScreen> createState() => _DashboardSymbolsScreenState();
}

class _DashboardSymbolsScreenState extends State<DashboardSymbolsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showAllSymbols = false;
  List<DashboardSymbol> _symbols = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSymbols();
  }

  Future<void> _loadSymbols() async {
    try {
      final jsonStr = await rootBundle.loadString('lib/screens/dashbord_symbols/dashobord_symble.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      setState(() {
        _symbols = jsonList.map((item) {
          return DashboardSymbol(
            name: item['name'] as String,
            fileName: item['fileName'] as String,
            severity: item['severity'] as String,
            color: _getColorFromString(item['color'] as String),
            meaning: item['meaning'] as String,
            action: item['action'] as String,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading symbols: $e')),
        );
      }
    }
  }

  Color _getColorFromString(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSymbolDetails(DashboardSymbol symbol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Icon & Name & Severity
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: symbol.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: symbol.color.withAlpha(40),
                        width: 1.0,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/dashboard_symbols/${symbol.fileName}',
                      colorFilter: ColorFilter.mode(symbol.color, BlendMode.srcIn),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symbol.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: symbol.color.withAlpha(25),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            symbol.severity.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: symbol.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              
              // Meaning
              const Text(
                'What it means:',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                symbol.meaning,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              
              const SizedBox(height: 20.0),
              
              // Action Recommended
              const Text(
                'Recommended Action:',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                symbol.action,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              
              const SizedBox(height: 28.0),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
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

    // Filter symbols based on search query
    final filteredSymbols = _symbols.where((symbol) {
      return symbol.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          symbol.severity.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // If not searching, restrict view based on _showAllSymbols flag
    final List<DashboardSymbol> displaySymbols;
    final bool showMoreCard;

    if (_searchQuery.isNotEmpty) {
      displaySymbols = filteredSymbols;
      showMoreCard = false;
    } else {
      if (_showAllSymbols) {
        displaySymbols = _symbols;
        showMoreCard = false;
      } else {
        // Show first 11 key items + "More..." card
        displaySymbols = _symbols.take(11).toList();
        showMoreCard = true;
      }
    }

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
          'Dashboard Symbols',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Section Header Block
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search dashboard symbols...',
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
                const SizedBox(height: 16.0),
                // Section Title Label
                const Text(
                  'All Symbols',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Grid View list
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.78,
              ),
              itemCount: displaySymbols.length + (showMoreCard ? 1 : 0),
              itemBuilder: (context, index) {
                // If it is the last item and showMoreCard is true, render the "More..." card
                if (showMoreCard && index == displaySymbols.length) {
                  return _buildMoreCard();
                }

                final symbol = displaySymbols[index];
                return _buildSymbolCard(symbol);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolCard(DashboardSymbol symbol) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color.fromARGB(20, 158, 158, 158),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(4, 0, 0, 0),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSymbolDetails(symbol),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Svg Icon
                SizedBox(
                  width: 44,
                  height: 44,
                  child: SvgPicture.asset(
                    'assets/dashboard_symbols/${symbol.fileName}',
                    colorFilter: ColorFilter.mode(symbol.color, BlendMode.srcIn),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10.0),
                // Name
                Text(
                  symbol.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color.fromARGB(20, 158, 158, 158),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(4, 0, 0, 0),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showAllSymbols = true;
            });
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // Icon
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSecondary,
                    size: 36,
                  ),
                ),
                SizedBox(height: 10.0),
                // Name
                Text(
                  'More...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
