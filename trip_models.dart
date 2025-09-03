class TripPlace {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String category;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final int estimatedDuration; // in minutes
  final String costEstimate;
  final List<String> tags;

  TripPlace({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.estimatedDuration,
    required this.costEstimate,
    required this.tags,
  });

  factory TripPlace.fromJson(Map<String, dynamic> json) {
    return TripPlace(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 60,
      costEstimate: json['costEstimate'] ?? '\$0',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'category': category,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'estimatedDuration': estimatedDuration,
      'costEstimate': costEstimate,
      'tags': tags,
    };
  }
}

class Trip {
  final String id;
  final String title;
  final DateTime createdAt;
  final String duration;
  final String peoplePreference;
  final List<String> selectedMoods;
  final List<TripPlace> places;
  final String totalCost;
  final int totalDuration; // in minutes
  final String status; // 'planned', 'completed', 'cancelled'
  final double? userRating;
  final String? userFeedback;

  Trip({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.duration,
    required this.peoplePreference,
    required this.selectedMoods,
    required this.places,
    required this.totalCost,
    required this.totalDuration,
    this.status = 'planned',
    this.userRating,
    this.userFeedback,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] ?? '',
      peoplePreference: json['peoplePreference'] ?? '',
      selectedMoods: List<String>.from(json['selectedMoods'] ?? []),
      places: (json['places'] as List<dynamic>?)
          ?.map((place) => TripPlace.fromJson(place))
          .toList() ?? [],
      totalCost: json['totalCost'] ?? '\$0',
      totalDuration: json['totalDuration'] ?? 0,
      status: json['status'] ?? 'planned',
      userRating: json['userRating']?.toDouble(),
      userFeedback: json['userFeedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'peoplePreference': peoplePreference,
      'selectedMoods': selectedMoods,
      'places': places.map((place) => place.toJson()).toList(),
      'totalCost': totalCost,
      'totalDuration': totalDuration,
      'status': status,
      'userRating': userRating,
      'userFeedback': userFeedback,
    };
  }

  Trip copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? duration,
    String? peoplePreference,
    List<String>? selectedMoods,
    List<TripPlace>? places,
    String? totalCost,
    int? totalDuration,
    String? status,
    double? userRating,
    String? userFeedback,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      peoplePreference: peoplePreference ?? this.peoplePreference,
      selectedMoods: selectedMoods ?? this.selectedMoods,
      places: places ?? this.places,
      totalCost: totalCost ?? this.totalCost,
      totalDuration: totalDuration ?? this.totalDuration,
      status: status ?? this.status,
      userRating: userRating ?? this.userRating,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }
}

class UserPreferences {
  final List<String> favoriteMoods;
  final String preferredPeopleType;
  final bool notificationsEnabled;
  final String preferredTimeSlot;

  UserPreferences({
    required this.favoriteMoods,
    required this.preferredPeopleType,
    required this.notificationsEnabled,
    required this.preferredTimeSlot,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      favoriteMoods: List<String>.from(json['favoriteMoods'] ?? []),
      preferredPeopleType: json['preferredPeopleType'] ?? 'Single',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      preferredTimeSlot: json['preferredTimeSlot'] ?? '3 hours',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favoriteMoods': favoriteMoods,
      'preferredPeopleType': preferredPeopleType,
      'notificationsEnabled': notificationsEnabled,
      'preferredTimeSlot': preferredTimeSlot,
    };
  }
}
