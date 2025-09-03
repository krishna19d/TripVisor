import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../services/api_service_factory.dart';

class ApiProvider extends ChangeNotifier {
  bool _useFreeApis = true;
  
  bool get useFreeApis => _useFreeApis;
  
  String get currentApiMode => _useFreeApis ? 'Free APIs' : 'Google APIs';
  
  String get currentProvider => _useFreeApis ? 'OpenStreetMap' : 'Google';
  
  List<String> get currentFeatures => _useFreeApis 
    ? ['100+ Indian Cities', 'OpenStreetMap Data', 'OSRM Routing', 'Zero Cost']
    : ['Global Coverage', 'Google Places', 'Google Directions', 'Premium Quality'];
  
  String get costInfo => _useFreeApis ? 'Free Forever' : 'Paid Service';
  
  void toggleApiMode() {
    _useFreeApis = !_useFreeApis;
    ApiServiceFactory.setUseFreeApis(_useFreeApis);
    notifyListeners();
  }
  
  void setFreeApis(bool useFree) {
    if (_useFreeApis != useFree) {
      _useFreeApis = useFree;
      ApiServiceFactory.setUseFreeApis(_useFreeApis);
      notifyListeners();
    }
  }
  
  // Get current services
  dynamic get cityService => ApiServiceFactory.getCityService();
  dynamic get geocodingService => ApiServiceFactory.getGeocodingService();
  dynamic get placesService => ApiServiceFactory.getPlacesService();
  dynamic get routingService => ApiServiceFactory.getRoutingService();
  
  Map<String, dynamic> get apiStatus => ApiServiceFactory.getApiStatus();
}
