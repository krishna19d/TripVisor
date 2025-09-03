import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/trip_models.dart';
import '../services/offline_storage_service.dart';
import '../utils/debug_logger.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final OfflineStorageService _storageService = OfflineStorageService();
  List<TripPlace> _savedPlaces = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
  }

  Future<void> _loadSavedPlaces() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // For now, we'll generate some mock saved places
      // In a real app, this would load from actual saved data
      _savedPlaces = _generateMockSavedPlaces();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      DebugLogger.error('Failed to load saved places', error: e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load saved places.';
      });
    }
  }

  List<TripPlace> _generateMockSavedPlaces() {
    return [
      TripPlace(
        id: 'saved_1',
        name: 'Favorite Restaurant',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=300',
        rating: 4.8,
        category: 'Restaurant',
        description: 'Amazing food and great atmosphere',
        address: '123 Gourmet Street',
        latitude: 37.7749,
        longitude: -122.4194,
        estimatedDuration: 90,
        costEstimate: '\$30-60',
        tags: ['fine dining', 'romantic', 'seafood'],
      ),
      TripPlace(
        id: 'saved_2',
        name: 'Beautiful Viewpoint',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300',
        rating: 4.9,
        category: 'Viewpoint',
        description: 'Breathtaking city views',
        address: 'Hilltop Drive',
        latitude: 37.8049,
        longitude: -122.4194,
        estimatedDuration: 60,
        costEstimate: 'Free',
        tags: ['scenic', 'photography', 'sunset'],
      ),
      TripPlace(
        id: 'saved_3',
        name: 'Cozy Bookstore Cafe',
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300',
        rating: 4.6,
        category: 'Cafe',
        description: 'Perfect place to read and relax',
        address: '456 Literary Lane',
        latitude: 37.7849,
        longitude: -122.4094,
        estimatedDuration: 120,
        costEstimate: '\$8-20',
        tags: ['books', 'coffee', 'quiet'],
      ),
      TripPlace(
        id: 'saved_4',
        name: 'Historic Art Museum',
        imageUrl: 'https://images.unsplash.com/photo-1565301660306-29e08751cc53?w=300',
        rating: 4.7,
        category: 'Museum',
        description: 'World-class art collection',
        address: '789 Culture Avenue',
        latitude: 37.7649,
        longitude: -122.4294,
        estimatedDuration: 180,
        costEstimate: '\$15-25',
        tags: ['art', 'history', 'culture'],
      ),
    ];
  }

  Future<void> _removeSavedPlace(TripPlace place) async {
    try {
      setState(() {
        _savedPlaces.removeWhere((p) => p.id == place.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${place.name} removed from saved places'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _savedPlaces.add(place);
              });
            },
          ),
        ),
      );
    } catch (e) {
      DebugLogger.error('Failed to remove saved place', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Places',
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
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality coming soon!')),
              );
            },
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
            Text('Loading saved places...'),
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
              onPressed: _loadSavedPlaces,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_savedPlaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No saved places yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring and save your favorite places!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Explore Places'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedPlaces,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedPlaces.length,
        itemBuilder: (context, index) {
          final place = _savedPlaces[index];
          
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
                  child: Stack(
                    children: [
                      Image.network(
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
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeSavedPlace(place),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Category
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
                              place.category,
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
                      
                      // Rating
                      Row(
                        children: [
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
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${place.estimatedDuration} min',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            place.costEstimate,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
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
                                // TODO: Add to trip
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Add ${place.name} to a trip'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add to Trip'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to place
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
}
