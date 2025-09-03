import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../services/city_service.dart';
import '../services/api_service_factory.dart';
import '../providers/api_provider.dart';
import '../models/enhanced_models.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<City> _cities = [];
  List<City> _filteredCities = [];
  String _selectedTier = 'All';
  bool _isLoading = true;
  dynamic _cityService;

  @override
  void initState() {
    super.initState();
    // Initialize the city service from API factory
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      _cityService = apiProvider.cityService;
      _loadCities();
    });
  }

  void _loadCities() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if we're using free APIs and call the appropriate method
      if (ApiServiceFactory.isUsingFreeApis) {
        _cities = await _cityService.getAllCities();
      } else {
        _cities = await _cityService.getAllCities();
      }
      _filteredCities = _cities;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cities: $e')),
        );
      }
    }
  }

  void _filterCities() {
    try {
      List<City> filtered;
      if (ApiServiceFactory.isUsingFreeApis) {
        // Use synchronous search for better performance with cached cities
        filtered = _cityService.searchCitiesSync(
          _cities,
          query: _searchController.text,
          tier: _selectedTier == 'All' ? null : _selectedTier,
        );
      } else {
        filtered = _cityService.searchCities(
          query: _searchController.text,
          tier: _selectedTier == 'All' ? null : _selectedTier,
        );
      }
      
      setState(() {
        _filteredCities = filtered;
      });
    } catch (e) {
      print('Error filtering cities: $e');
      // Fallback to showing all cities
      setState(() {
        _filteredCities = _cities;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Destination'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterCities(),
                  decoration: InputDecoration(
                    hintText: 'Search cities...',
                    prefixIcon: Icon(MdiIcons.magnify),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(MdiIcons.close),
                            onPressed: () {
                              _searchController.clear();
                              _filterCities();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tier Filter Chips
                Row(
                  children: [
                    Text(
                      'Filter by tier:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All', 
                            'Global Tier 1', 
                            'Global Tier 2', 
                            'Indian Tier 1', 
                            'Indian Tier 2'
                          ].map((tier) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  tier,
                                  style: TextStyle(fontSize: 12),
                                ),
                                selected: _selectedTier == tier,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTier = tier;
                                  });
                                  _filterCities();
                                },
                                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                checkmarkColor: Theme.of(context).primaryColor,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Cities List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredCities.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredCities.length,
                        itemBuilder: (context, index) {
                          return _buildCityCard(_filteredCities[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.cityVariantOutline,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No cities found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(City city) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(city),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // City Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  MdiIcons.cityVariant,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // City Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            city.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTierColor(city.tier).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            city.tier,
                            style: TextStyle(
                              color: _getTierColor(city.tier),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city.state,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          MdiIcons.mapMarker,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${city.majorAttractions.length} major attractions',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ),
                        Icon(
                          MdiIcons.chevronRight,
                          size: 20,
                          color: Theme.of(context).disabledColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Global Tier 1':
        return Colors.purple;
      case 'Global Tier 2':
        return Colors.deepPurple;
      case 'Indian Tier 1':
        return Colors.green;
      case 'Indian Tier 2':
        return Colors.orange;
      case 'Tier 1': // Legacy support
        return Colors.green;
      case 'Tier 2': // Legacy support
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
