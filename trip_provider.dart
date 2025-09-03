import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripvisor/models/trip_models.dart';
import 'package:tripvisor/models/enhanced_models.dart';
import 'package:tripvisor/utils/constants.dart';
import 'package:tripvisor/services/api_service_factory.dart';
import 'package:tripvisor/services/cost_estimation_service.dart';

class TripProvider with ChangeNotifier {
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TripProvider() {
    _loadTripsFromStorage();
  }

  Future<void> _loadTripsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getString(AppConstants.userTripsKey);
      
      if (tripsJson != null) {
        final List<dynamic> tripsList = json.decode(tripsJson);
        _trips = tripsList.map((trip) => Trip.fromJson(trip)).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load trips: $e';
      notifyListeners();
    }
  }

  Future<void> _saveTripsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = json.encode(_trips.map((trip) => trip.toJson()).toList());
      await prefs.setString(AppConstants.userTripsKey, tripsJson);
    } catch (e) {
      _error = 'Failed to save trips: $e';
      notifyListeners();
    }
  }

  Future<Trip> generateTrip({
    required String peoplePreference,
    required List<String> selectedMoods,
    required String duration,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock trip data
      final trip = _generateMockTrip(
        peoplePreference: peoplePreference,
        selectedMoods: selectedMoods,
        duration: duration,
      );

      _trips.insert(0, trip);
      await _saveTripsToStorage();
      
      _isLoading = false;
      notifyListeners();
      
      return trip;
    } catch (e) {
      _error = 'Failed to generate trip: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Trip> generateTripFromItinerary({
    required TripItinerary itinerary,
    required TripPreferences preferences,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert TripItinerary to Trip model efficiently
      final places = itinerary.items.map((item) {
        // Use null-aware operators for better performance
        final photoUrl = item.place.photoUrls.isNotEmpty 
          ? item.place.photoUrls.first 
          : 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop&auto=format';
        
        return TripPlace(
          id: item.place.placeId ?? '',
          name: item.place.name,
          category: _mapCategoryToType(item.place.category),
          description: item.place.description ?? '',
          rating: item.place.rating,
          estimatedDuration: item.duration,
          costEstimate: '\$${item.estimatedCost.toInt()}',
          imageUrl: photoUrl,
          address: item.place.address ?? '',
          latitude: item.place.location.latitude,
          longitude: item.place.location.longitude,
          tags: item.place.types,
        );
      }).toList();

      final trip = Trip(
        id: itinerary.id,
        title: 'Trip to ${preferences.destination}',
        createdAt: itinerary.createdAt,
        duration: preferences.duration,
        peoplePreference: preferences.groupSize.toString(),
        selectedMoods: preferences.interests,
        places: places,
        totalCost: '\$${itinerary.totalCost.toInt()}',
        totalDuration: itinerary.totalDuration,
      );

      _trips.insert(0, trip);
      
      // Save to storage asynchronously without blocking the UI
      _saveTripsToStorage().catchError((error) {
        print('Error saving trips to storage: $error');
      });
      
      _isLoading = false;
      notifyListeners();
      
      return trip;
    } catch (e) {
      _error = 'Failed to generate trip from itinerary: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  String _mapCategoryToType(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.restaurant:
        return 'Restaurant';
      case PlaceCategory.attraction:
        return 'Attraction';
      case PlaceCategory.shopping:
        return 'Shopping';
      case PlaceCategory.entertainment:
        return 'Entertainment';
      case PlaceCategory.culture:
        return 'Cultural';
      case PlaceCategory.nature:
        return 'Nature';
      case PlaceCategory.adventure:
        return 'Adventure';
      case PlaceCategory.relaxation:
        return 'Relaxation';
      default:
        return 'Other';
    }
  }

  Trip _generateMockTrip({
    required String peoplePreference,
    required List<String> selectedMoods,
    required String duration,
  }) {
    final random = Random();
    final tripId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Generate places based on selected moods
    final places = _generateMockPlaces(selectedMoods, duration);
    
    // Calculate total cost and duration
    final totalCost = _calculateTotalCost(places);
    final totalDuration = places.fold<int>(0, (sum, place) => sum + place.estimatedDuration);
    
    return Trip(
      id: tripId,
      title: _generateTripTitle(selectedMoods, peoplePreference),
      createdAt: DateTime.now(),
      duration: duration,
      peoplePreference: peoplePreference,
      selectedMoods: selectedMoods,
      places: places,
      totalCost: totalCost,
      totalDuration: totalDuration,
      status: 'planned',
    );
  }

  List<TripPlace> _generateMockPlaces(List<String> moods, String duration) {
    final random = Random();
    int numberOfPlaces;
    
    // Determine number of places based on duration
    switch (duration) {
      case '1 hour':
        numberOfPlaces = 1;
        break;
      case '3 hours':
        numberOfPlaces = 2 + random.nextInt(2); // 2-3 places
        break;
      case '5 hours':
        numberOfPlaces = 3 + random.nextInt(2); // 3-4 places
        break;
      case '1 day':
        numberOfPlaces = 4 + random.nextInt(3); // 4-6 places
        break;
      default:
        numberOfPlaces = 3;
    }

    final List<TripPlace> places = [];
    final mockPlaces = _getMockPlacesData();
    
    // Filter places based on moods and randomly select
    final filteredPlaces = mockPlaces.where((place) {
      return place.tags.any((tag) => moods.contains(tag));
    }).toList();
    
    if (filteredPlaces.isEmpty) {
      // If no filtered places, use random places
      for (int i = 0; i < numberOfPlaces && i < mockPlaces.length; i++) {
        places.add(mockPlaces[random.nextInt(mockPlaces.length)]);
      }
    } else {
      // Use filtered places
      final shuffled = List.from(filteredPlaces)..shuffle(random);
      for (int i = 0; i < numberOfPlaces && i < shuffled.length; i++) {
        places.add(shuffled[i]);
      }
    }

    return places;
  }

  String _generateTripTitle(List<String> moods, String peoplePreference) {
    final random = Random();
    final moodString = moods.isNotEmpty ? moods.first : 'Adventure';
    final prefixes = ['Amazing', 'Perfect', 'Wonderful', 'Great', 'Fantastic'];
    final prefix = prefixes[random.nextInt(prefixes.length)];
    
    return '$prefix $moodString Trip for ${peoplePreference.toLowerCase()}';
  }

  String _calculateTotalCost(List<TripPlace> places) {
    // Use the improved cost estimation service for realistic pricing
    final groupSize = 2; // Default group size for calculation
    final totalDistance = 50.0; // Estimated average trip distance in km
    const transportMode = 'driving'; // Default transport mode
    
    final totalCost = CostEstimationService.calculateTotalTripCost(
      places,
      totalDistance,
      transportMode,
      groupSize,
    );
    
    return CostEstimationService.formatCostEstimate(totalCost);
  }

  List<TripPlace> _getMockPlacesData() {
    final random = Random();
    
    return [
      TripPlace(
        id: '1',
        name: 'India Gate',
        imageUrl: AppConstants.placeholderImages[0],
        rating: 4.5 + random.nextDouble() * 0.5,
        category: 'Monument',
        description: 'Iconic war memorial arch in the heart of Delhi.',
        address: 'Rajpath, India Gate, New Delhi, Delhi 110001',
        latitude: 28.612894,
        longitude: 77.229446,
        estimatedDuration: 90,
        costEstimate: 'Free',
        tags: ['Monument', 'Photography', 'History', 'Patriotic'],
      ),
      TripPlace(
        id: '2',
        name: 'Red Fort',
        imageUrl: AppConstants.placeholderImages[1],
        rating: 4.7 + random.nextDouble() * 0.3,
        category: 'Historical',
        description: 'Historic fortified palace of the Mughal emperors.',
        address: 'Netaji Subhash Marg, Lal Qila, Chandni Chowk, New Delhi',
        latitude: 28.656159,
        longitude: 77.241025,
        estimatedDuration: 120,
        costEstimate: '₹50',
        tags: ['Historical', 'Architecture', 'Photography', 'Education'],
      ),
      TripPlace(
        id: '3',
        name: 'Karim Restaurant',
        imageUrl: AppConstants.placeholderImages[2],
        rating: 4.3 + random.nextDouble() * 0.4,
        category: 'Food',
        description: 'Legendary Mughlai cuisine restaurant since 1913.',
        address: 'Gali Kababian, Jama Masjid, Old Delhi',
        latitude: 28.650971,
        longitude: 77.233668,
        estimatedDuration: 75,
        costEstimate: '₹400',
        tags: ['Food', 'Mughlai', 'Heritage', 'Authentic'],
      ),
      TripPlace(
        id: '4',
        name: 'Lotus Temple',
        imageUrl: AppConstants.placeholderImages[3],
        rating: 4.1 + random.nextDouble() * 0.6,
        category: 'Religious',
        description: 'Beautiful lotus-shaped Baháí House of Worship.',
        address: 'Lotus Temple Rd, Bahapur, Kalkaji, New Delhi',
        latitude: 28.553492,
        longitude: 77.258968,
        estimatedDuration: 60,
        costEstimate: 'Free',
        tags: ['Religious', 'Architecture', 'Peace', 'Meditation'],
      ),
      TripPlace(
        id: '5',
        name: 'Qutub Minar',
        imageUrl: AppConstants.placeholderImages[4],
        rating: 4.6 + random.nextDouble() * 0.4,
        category: 'Heritage',
        description: 'UNESCO World Heritage Site - tallest brick minaret.',
        address: 'Seth Sarai, Mehrauli, New Delhi',
        latitude: 28.524408,
        longitude: 77.185005,
        estimatedDuration: 120,
        costEstimate: '₹30',
        tags: ['Heritage', 'History', 'Photography', 'Architecture'],
      ),
      TripPlace(
        id: '6',
        name: 'Humayuns Tomb',
        imageUrl: AppConstants.placeholderImages[5],
        rating: 4.2 + random.nextDouble() * 0.5,
        category: 'Heritage',
        description: 'UNESCO World Heritage Site - Mughal garden tomb.',
        address: 'Mathura Rd, Nizamuddin, New Delhi',
        latitude: 28.593276,
        longitude: 77.250692,
        estimatedDuration: 120,
        costEstimate: '₹30',
        tags: ['Heritage', 'Architecture', 'Photography', 'History'],
      ),
      TripPlace(
        id: '7',
        name: 'Chandni Chowk Market',
        imageUrl: AppConstants.placeholderImages[6],
        rating: 4.4 + random.nextDouble() * 0.3,
        category: 'Shopping',
        description: 'Historic market area famous for shopping and street food.',
        address: 'Chandni Chowk, Old Delhi',
        latitude: 28.650971,
        longitude: 77.230360,
        estimatedDuration: 90,
        costEstimate: '₹500',
        tags: ['Shopping', 'Street Food', 'Culture', 'Heritage'],
      ),
      TripPlace(
        id: '8',
        name: 'Akshardham Temple',
        imageUrl: AppConstants.placeholderImages[7],
        rating: 4.5 + random.nextDouble() * 0.4,
        category: 'Religious',
        description: 'Modern Hindu temple complex with stunning architecture.',
        address: 'NH 24, Akshardham Setu, New Delhi',
        latitude: 28.622621,
        longitude: 77.277397,
        estimatedDuration: 120,
        costEstimate: 'Free',
        tags: ['Religious', 'Architecture', 'Culture', 'Family'],
      ),
    ];
  }

  Future<void> updateTripFeedback(String tripId, double rating, String feedback) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      _trips[tripIndex] = _trips[tripIndex].copyWith(
        userRating: rating,
        userFeedback: feedback,
        status: 'completed',
      );
      await _saveTripsToStorage();
      notifyListeners();
    }
  }

  Future<void> markTripAsCompleted(String tripId) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      _trips[tripIndex] = _trips[tripIndex].copyWith(
        status: 'completed',
      );
      await _saveTripsToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((trip) => trip.id == tripId);
    await _saveTripsToStorage();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
