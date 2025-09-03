import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/trip_models.dart';
import '../services/location_service.dart';
import '../utils/debug_logger.dart';

class ExploreNearbyScreen extends StatefulWidget {
  const ExploreNearbyScreen({super.key});

  @override
  State<ExploreNearbyScreen> createState() => _ExploreNearbyScreenState();
}

class _ExploreNearbyScreenState extends State<ExploreNearbyScreen> {
  final LocationService _locationService = LocationService();
  List<TripPlace> _nearbyPlaces = [];
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current location
      _currentPosition = await _locationService.getCurrentLocation();
      
      // Generate nearby places (mock data for now)
      _nearbyPlaces = _generateNearbyPlaces(_currentPosition!);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      DebugLogger.error('Failed to load nearby places', error: e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load nearby places. Please check your location permissions.';
      });
    }
  }

  List<TripPlace> _generateNearbyPlaces(Position position) {
    // Mock nearby places data
    return [
      TripPlace(
        id: 'nearby_1',
        name: 'Local Coffee Shop',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300',
        rating: 4.5,
        category: 'Cafe',
        description: 'Cozy coffee shop with great atmosphere',
        address: '123 Main Street',
        latitude: position.latitude + 0.001,
        longitude: position.longitude + 0.001,
        estimatedDuration: 30,
        costEstimate: '\$5-15',
        tags: ['coffee', 'breakfast', 'wifi'],
      ),
      TripPlace(
        id: 'nearby_2',
        name: 'City Park',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300',
        rating: 4.2,
        category: 'Park',
        description: 'Beautiful park for walking and relaxation',
        address: '456 Park Avenue',
        latitude: position.latitude - 0.002,
        longitude: position.longitude + 0.002,
        estimatedDuration: 60,
        costEstimate: 'Free',
        tags: ['nature', 'walking', 'family'],
      ),
      TripPlace(
        id: 'nearby_3',
        name: 'Local Museum',
        imageUrl: 'https://images.unsplash.com/photo-1565301660306-29e08751cc53?w=300',
        rating: 4.7,
        category: 'Museum',
        description: 'Fascinating local history and culture',
        address: '789 Culture Street',
        latitude: position.latitude + 0.003,
        longitude: position.longitude - 0.001,
        estimatedDuration: 120,
        costEstimate: '\$10-20',
        tags: ['culture', 'history', 'indoor'],
      ),
      TripPlace(
        id: 'nearby_4',
        name: 'Riverside Restaurant',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=300',
        rating: 4.4,
        category: 'Restaurant',
        description: 'Fine dining with river views',
        address: '321 River Road',
        latitude: position.latitude - 0.001,
        longitude: position.longitude - 0.003,
        estimatedDuration: 90,
        costEstimate: '\$25-50',
        tags: ['dining', 'view', 'romantic'],
      ),
      TripPlace(
        id: 'nearby_5',
        name: 'Shopping Center',
        imageUrl: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=300',
        rating: 4.0,
        category: 'Shopping',
        description: 'Modern shopping center with various stores',
        address: '654 Commerce Blvd',
        latitude: position.latitude + 0.002,
        longitude: position.longitude + 0.003,
        estimatedDuration: 180,
        costEstimate: '\$20-100',
        tags: ['shopping', 'indoor', 'variety'],
      ),
    ];
  }

  double _calculateDistance(TripPlace place) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      place.latitude,
      place.longitude,
    ) / 1000; // Convert to kilometers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Nearby',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyPlaces,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding nearby places...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNearbyPlaces,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyPlaces,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _nearbyPlaces.length,
        itemBuilder: (context, index) {
          final place = _nearbyPlaces[index];
          final distance = _calculateDistance(place);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    place.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Distance
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Category and Rating
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(place.category),
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.category,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        place.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: place.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Add to saved places
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${place.name} saved to favorites!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to place or add to trip
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Navigate to ${place.name}'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('Navigate'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cafe':
        return MdiIcons.coffee;
      case 'park':
        return MdiIcons.tree;
      case 'museum':
        return MdiIcons.bank;
      case 'restaurant':
        return MdiIcons.silverwareForkKnife;
      case 'shopping':
        return MdiIcons.shopping;
      default:
        return MdiIcons.mapMarker;
    }
  }
}
