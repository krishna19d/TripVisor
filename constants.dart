class AppConstants {
  // App Information
  static const String appName = 'Tripvisor';
  static const String appVersion = '1.0.4';
  
  // API Constants (placeholders for future integration)
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  static const String googleDirectionsApiKey = 'YOUR_GOOGLE_DIRECTIONS_API_KEY';
  static const String aiApiBaseUrl = 'YOUR_AI_API_BASE_URL';
  
  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String userTripsKey = 'user_trips';
  static const String userPreferencesKey = 'user_preferences';
  
  // Default Values
  static const String defaultProfileImage = 'https://via.placeholder.com/150';
  
  // Trip Categories/Moods
  static const List<String> tripMoods = [
    'Nature',
    'Food',
    'Culture',
    'Adventure',
    'Shopping',
    'Relaxation',
    'Photography',
    'Nightlife',
    'Events',
    'Spiritual',
    'Sports',
    'Music',
  ];
  
  // People Preferences
  static const List<String> peoplePreferences = [
    'Single',
    'Couple',
    'Group',
  ];
  
  // Time Options
  static const List<String> timeOptions = [
    '1 hour',
    '3 hours',
    '5 hours',
    '1 day',
  ];
  
  // Dummy Image URLs for placeholder content
  static const List<String> placeholderImages = [
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
    'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
    'https://images.unsplash.com/photo-1518623489648-a173ef7824f3?w=400',
    'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=400',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
  ];
}

// Animation Durations
class AnimationConstants {
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}

// String Constants
class StringConstants {
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String myTrip = 'My Trips';
  static const String profile = 'Profile';
  
  // Dashboard
  static const String createNewTrip = 'Create New Trip';
  static const String generateTripPlan = 'Generate Trip Plan';
  static const String selectPeople = 'Who\'s going?';
  static const String selectMood = 'What\'s your mood?';
  static const String selectTime = 'How much time do you have?';
  
  // Profile
  static const String darkMode = 'Dark Mode';
  static const String notifications = 'Notifications';
  static const String about = 'About';
  static const String logout = 'Logout';
  
  // General
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String noTrips = 'No trips found';
  static const String retry = 'Retry';
}
