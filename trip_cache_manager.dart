import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_models.dart';

/// High-performance cache manager for trip data
class TripCacheManager {
  static final TripCacheManager _instance = TripCacheManager._internal();
  factory TripCacheManager() => _instance;
  TripCacheManager._internal();

  // In-memory caches for instant access
  final Map<String, List<PlaceDetails>> _placesCache = {};
  final Map<String, City> _cityCache = {};
  final Map<String, TripItinerary> _itineraryCache = {};
  
  // Cache expiry times (in milliseconds)
  static const int _cacheExpiryMs = 30 * 60 * 1000; // 30 minutes
  final Map<String, int> _cacheTimestamps = {};

  /// Cache places for a specific location and interest
  void cachePlaces(String key, List<PlaceDetails> places) {
    _placesCache[key] = places;
    _cacheTimestamps[key] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Get cached places if available and not expired
  List<PlaceDetails>? getCachedPlaces(String key) {
    if (!_placesCache.containsKey(key)) return null;
    
    final timestamp = _cacheTimestamps[key] ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - timestamp > _cacheExpiryMs) {
      _placesCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _placesCache[key];
  }

  /// Cache city data
  void cacheCity(String cityId, City city) {
    _cityCache[cityId] = city;
    _cacheTimestamps['city_$cityId'] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Get cached city if available
  City? getCachedCity(String cityId) {
    if (!_cityCache.containsKey(cityId)) return null;
    
    final timestamp = _cacheTimestamps['city_$cityId'] ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - timestamp > _cacheExpiryMs) {
      _cityCache.remove(cityId);
      _cacheTimestamps.remove('city_$cityId');
      return null;
    }
    
    return _cityCache[cityId];
  }

  /// Cache complete trip itinerary
  void cacheItinerary(String key, TripItinerary itinerary) {
    _itineraryCache[key] = itinerary;
    _cacheTimestamps['itinerary_$key'] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Get cached trip itinerary
  TripItinerary? getCachedItinerary(String key) {
    if (!_itineraryCache.containsKey(key)) return null;
    
    final timestamp = _cacheTimestamps['itinerary_$key'] ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - timestamp > _cacheExpiryMs) {
      _itineraryCache.remove(key);
      _cacheTimestamps.remove('itinerary_$key');
      return null;
    }
    
    return _itineraryCache[key];
  }

  /// Generate cache key for trip preferences
  static String generateTripCacheKey({
    required String cityId,
    required List<String> interests,
    required String duration,
    required int groupSize,
  }) {
    final sortedInterests = List<String>.from(interests)..sort();
    return '${cityId}_${sortedInterests.join('_')}_${duration}_$groupSize';
  }

  /// Generate cache key for places
  static String generatePlacesCacheKey({
    required double latitude,
    required double longitude,
    required String interest,
    double radius = 10.0,
  }) {
    return '${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}_${interest}_$radius';
  }

  /// Clear expired cache entries
  void clearExpiredCache() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now - entry.value > _cacheExpiryMs) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cacheTimestamps.remove(key);
      _placesCache.remove(key);
      _cityCache.remove(key.replaceFirst('city_', ''));
      _itineraryCache.remove(key.replaceFirst('itinerary_', ''));
    }
  }

  /// Clear all cache
  void clearAllCache() {
    _placesCache.clear();
    _cityCache.clear();
    _itineraryCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'places': _placesCache.length,
      'cities': _cityCache.length,
      'itineraries': _itineraryCache.length,
      'total_keys': _cacheTimestamps.length,
    };
  }

  /// Preload popular destinations data
  Future<void> preloadPopularDestinations() async {
    // This can be called on app startup to cache popular destinations
    clearExpiredCache();
  }

  /// Save critical cache data to persistent storage
  Future<void> saveCriticalCacheToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save city cache
      final cityData = <String, Map<String, dynamic>>{};
      for (final entry in _cityCache.entries) {
        cityData[entry.key] = entry.value.toJson();
      }
      await prefs.setString('cached_cities', jsonEncode(cityData));
      
      print('Critical cache saved to disk');
    } catch (e) {
      print('Error saving cache to disk: $e');
    }
  }

  /// Load critical cache data from persistent storage
  Future<void> loadCriticalCacheFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load city cache
      final cityDataString = prefs.getString('cached_cities');
      if (cityDataString != null) {
        final cityData = jsonDecode(cityDataString) as Map<String, dynamic>;
        for (final entry in cityData.entries) {
          _cityCache[entry.key] = City.fromJson(entry.value);
          _cacheTimestamps['city_${entry.key}'] = DateTime.now().millisecondsSinceEpoch;
        }
      }
      
      print('Critical cache loaded from disk');
    } catch (e) {
      print('Error loading cache from disk: $e');
    }
  }
}
