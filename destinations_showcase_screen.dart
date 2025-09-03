import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/enhanced_models.dart';
import '../services/free_city_service.dart';
import 'city_selection_screen.dart';

class DestinationsShowcaseScreen extends StatefulWidget {
  const DestinationsShowcaseScreen({super.key});

  @override
  State<DestinationsShowcaseScreen> createState() => _DestinationsShowcaseScreenState();
}

class _DestinationsShowcaseScreenState extends State<DestinationsShowcaseScreen> {
  final FreeCityService _cityService = FreeCityService();
  List<City> _globalTier1Cities = [];
  List<City> _globalTier2Cities = [];
  List<City> _indianTier1Cities = [];
  List<City> _indianTier2Cities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      final allCities = await _cityService.getAllCities();
      
      setState(() {
        _globalTier1Cities = allCities.where((city) => city.tier == 'Global Tier 1').toList();
        _globalTier2Cities = allCities.where((city) => city.tier == 'Global Tier 2').toList();
        _indianTier1Cities = allCities.where((city) => city.tier == 'Indian Tier 1').toList();
        _indianTier2Cities = allCities.where((city) => city.tier == 'Indian Tier 2').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Free Global Destinations',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade600,
                      Colors.purple.shade600,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        MdiIcons.earth,
                        size: 60,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_globalTier1Cities.length + _globalTier2Cities.length + _indianTier1Cities.length + _indianTier2Cities.length)} Free Destinations',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // Global Tier 1 Section
            _buildSectionHeader('🌟 Global Tier 1 Cities', 'World\'s premier destinations', Colors.purple),
            _buildCityGrid(_globalTier1Cities, Colors.purple),
            
            // Global Tier 2 Section
            _buildSectionHeader('🏙️ Global Tier 2 Cities', 'Amazing international destinations', Colors.deepPurple),
            _buildCityGrid(_globalTier2Cities, Colors.deepPurple),
            
            // Indian Tier 1 Section
            _buildSectionHeader('🇮🇳 Indian Tier 1 Cities', 'India\'s metropolitan hubs', Colors.green),
            _buildCityGrid(_indianTier1Cities, Colors.green),
            
            // Indian Tier 2 Section
            _buildSectionHeader('🏛️ Indian Tier 2 Cities', 'Rich cultural heritage cities', Colors.orange),
            _buildCityGrid(_indianTier2Cities, Colors.orange),
            
            // Call to Action
            _buildCallToAction(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityGrid(List<City> cities, Color accentColor) {
    if (cities.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final city = cities[index];
            return _buildCityCard(city, accentColor);
          },
          childCount: cities.length,
        ),
      ),
    );
  }

  Widget _buildCityCard(City city, Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectCity(city),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Image/Placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      // City Image
                      Positioned.fill(
                        child: Image.network(
                          city.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to gradient if image fails to load
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor.withOpacity(0.6),
                                    accentColor.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: CustomPaint(
                                painter: CityPatternPainter(accentColor),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor.withOpacity(0.6),
                                    accentColor.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                      // Gradient overlay for better text visibility
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCityIcon(city.name),
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              city.tier.split(' ').last,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
            // City Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      city.state,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          MdiIcons.mapMarker,
                          size: 12,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Free destination',
                            style: TextStyle(
                              fontSize: 10,
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallToAction() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.purple.shade500],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              MdiIcons.airplaneTakeoff,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Start Planning Your Trip',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'All destinations are completely FREE to plan with zero API costs!',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(255, 255, 255, 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CitySelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose Destination',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(MdiIcons.chevronRight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCity(City city) {
    Navigator.pop(context, city);
  }

  IconData _getCityIcon(String cityName) {
    final icons = {
      'Tokyo': MdiIcons.templeHindu,
      'New York': MdiIcons.cityVariant,
      'London': MdiIcons.crown,
      'Paris': MdiIcons.towerBeach,
      'Singapore': MdiIcons.cityVariant,
      'Dubai': MdiIcons.mosque,
      'Mumbai': MdiIcons.cityVariant,
      'Delhi': MdiIcons.mosque,
      'Bangalore': MdiIcons.chip,
      'Chennai': MdiIcons.templeHindu,
    };
    
    return icons[cityName] ?? MdiIcons.cityVariant;
  }
}

class CityPatternPainter extends CustomPainter {
  final Color color;

  CityPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw subtle grid pattern
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    
    for (int i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
