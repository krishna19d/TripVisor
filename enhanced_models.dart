class City {
  final String id;
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final String tier;
  final List<String> majorAttractions;
  final String imageUrl;
  final String description;

  City({
    required this.id,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.tier,
    required this.majorAttractions,
    required this.imageUrl,
    required this.description,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      state: json['state'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      tier: json['tier'],
      majorAttractions: List<String>.from(json['majorAttractions']),
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'tier': tier,
      'majorAttractions': majorAttractions,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}


class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final List<String> savedTrips;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    this.savedTrips = const [],
    this.preferences = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      createdAt: DateTime.parse(json['createdAt']),
      savedTrips: List<String>.from(json['savedTrips'] ?? []),
      preferences: json['preferences'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'savedTrips': savedTrips,
      'preferences': preferences,
    };
  }
}

class PlaceDetails {
  final String? placeId;
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final double rating;
  final int userRatingsTotal;
  final List<String> types;
  final String? photoReference;
  final List<String> photoUrls;
  final String? website;
  final String? phoneNumber;
  final Map<String, dynamic>? openingHours;
  final double? priceLevel;
  final PlaceCategory category;
  final String? description;
  final Location location;

  PlaceDetails({
    this.placeId,
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.userRatingsTotal,
    required this.types,
    this.photoReference,
    this.photoUrls = const [],
    this.website,
    this.phoneNumber,
    this.openingHours,
    this.priceLevel,
    required this.category,
    this.description,
    required this.location,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return PlaceDetails(
      placeId: json['place_id'],
      id: json['place_id'] ?? json['id'],
      name: json['name'],
      address: json['formatted_address'] ?? json['vicinity'] ?? '',
      latitude: geometry['lat'].toDouble(),
      longitude: geometry['lng'].toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: json['user_ratings_total'] ?? 0,
      types: List<String>.from(json['types'] ?? []),
      photoReference: json['photos']?[0]?['photo_reference'],
      photoUrls: json['photoUrls'] != null ? List<String>.from(json['photoUrls']) : [],
      website: json['website'],
      phoneNumber: json['formatted_phone_number'],
      openingHours: json['opening_hours'],
      priceLevel: json['price_level']?.toDouble(),
      category: PlaceCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => PlaceCategory.attraction,
      ),
      description: json['description'],
      location: Location(
        latitude: geometry['lat'].toDouble(),
        longitude: geometry['lng'].toDouble(),
        address: json['formatted_address'] ?? json['vicinity'] ?? '',
      ),
    );
  }
}

enum PlaceCategory {
  restaurant,
  attraction,
  shopping,
  entertainment,
  culture,
  nature,
  adventure,
  relaxation,
  other
}

enum TripBudget {
  low,
  medium,
  high
}

class Location {
  final double latitude;
  final double longitude;
  final String? address;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class TripPreferences {
  final String destination;
  final String duration;
  final int groupSize;
  final List<String> interests;
  final TripBudget budget;

  TripPreferences({
    required this.destination,
    required this.duration,
    required this.groupSize,
    required this.interests,
    required this.budget,
  });
}

class TripItinerary {
  final String id;
  final String cityId;
  final String cityName;
  final DateTime startTime;
  final DateTime endTime;
  final List<ItineraryItem> items;
  final double totalDistance;
  final int totalDuration; // in minutes
  final double totalCost;
  final double estimatedCost;
  final DateTime createdAt;
  final String mood;
  final List<String> interests;
  final String peoplePreference;

  TripItinerary({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.startTime,
    required this.endTime,
    required this.items,
    required this.totalDistance,
    required this.totalDuration,
    required this.totalCost,
    required this.estimatedCost,
    required this.createdAt,
    required this.mood,
    required this.interests,
    required this.peoplePreference,
  });

  factory TripItinerary.fromJson(Map<String, dynamic> json) {
    return TripItinerary(
      id: json['id'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      items: (json['items'] as List)
          .map((item) => ItineraryItem.fromJson(item))
          .toList(),
      totalDistance: json['totalDistance'].toDouble(),
      totalDuration: json['totalDuration'],
      totalCost: json['totalCost']?.toDouble() ?? 0.0,
      estimatedCost: json['estimatedCost'].toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      mood: json['mood'],
      interests: List<String>.from(json['interests']),
      peoplePreference: json['peoplePreference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityId': cityId,
      'cityName': cityName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'estimatedCost': estimatedCost,
      'mood': mood,
      'interests': interests,
      'peoplePreference': peoplePreference,
    };
  }
}

class ItineraryItem {
  final String id;
  final PlaceDetails place;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int duration; // Same as durationMinutes for compatibility
  final double estimatedCost;
  final String category;
  final int order;
  final String? notes;

  ItineraryItem({
    required this.id,
    required this.place,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.estimatedCost,
    required this.category,
    required this.order,
    this.notes,
  }) : duration = durationMinutes;

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'],
      place: PlaceDetails.fromJson(json['place']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationMinutes: json['durationMinutes'],
      estimatedCost: json['estimatedCost'].toDouble(),
      category: json['category'],
      order: json['order'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place': place.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'estimatedCost': estimatedCost,
      'category': category,
      'order': order,
      'notes': notes,
    };
  }
}

extension PlaceDetailsExtension on PlaceDetails {
  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'name': name,
      'formatted_address': address,
      'geometry': {
        'location': {
          'lat': latitude,
          'lng': longitude,
        }
      },
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'types': types,
      'photos': photoReference != null
          ? [
              {'photo_reference': photoReference}
            ]
          : null,
      'website': website,
      'formatted_phone_number': phoneNumber,
      'opening_hours': openingHours,
      'price_level': priceLevel,
    };
  }
}
