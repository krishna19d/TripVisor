import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tripvisor/providers/trip_provider.dart';
import 'package:tripvisor/providers/api_provider.dart';
import 'package:tripvisor/screens/trip_result_screen.dart';
import 'package:tripvisor/screens/city_selection_screen.dart';
import 'package:tripvisor/models/enhanced_models.dart';
import 'package:tripvisor/services/trip_planner_service.dart';
import 'package:tripvisor/services/api_service_factory.dart';
import 'package:tripvisor/services/ads_service.dart';
import 'package:tripvisor/services/ad_manager.dart';
import 'package:tripvisor/utils/performance_optimizer.dart';
import 'package:tripvisor/utils/constants.dart';
import 'package:tripvisor/widgets/custom_chip.dart';
import 'package:tripvisor/widgets/loading_overlay.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({super.key});

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  City? selectedCity;
  String? selectedPeoplePreference;
  List<String> selectedMoods = [];
  String? selectedTimeOption;
  bool isGenerating = false;
  late AdManager _adManager;

  // Static icon maps for better performance (non-const since MdiIcons are not compile-time constants)
  static final Map<String, IconData> _moodIcons = {
    'Nature': MdiIcons.tree,
    'Food': MdiIcons.foodVariant,
    'Culture': MdiIcons.bank,
    'Adventure': MdiIcons.hiking,
    'Shopping': MdiIcons.shopping,
    'Relaxation': MdiIcons.spa,
    'Photography': MdiIcons.camera,
    'Nightlife': MdiIcons.glassMug,
    'Events': MdiIcons.calendar,
    'Spiritual': MdiIcons.church,
    'Sports': MdiIcons.soccer,
    'Music': MdiIcons.music,
  };

  static final Map<String, IconData> _peopleIcons = {
    'Single': MdiIcons.account,
    'Couple': MdiIcons.accountHeart,
    'Group': MdiIcons.accountGroup,
  };

  @override
  void initState() {
    super.initState();
    _adManager = AdManager();
    // Preload an interstitial ad for better user experience
    _adManager.preloadAds();
  }

  @override
  void dispose() {
    // Note: Don't dispose AdManager here as it's a singleton used app-wide
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),

                  // City Selection Section
                  _buildSectionTitle(
                    'Select Destination',
                    MdiIcons.cityVariant,
                  ),
                  const SizedBox(height: 16),
                  _buildCitySelectionSection(),
                  const SizedBox(height: 32),

                  // People Preference Section
                  _buildSectionTitle(
                    StringConstants.selectPeople,
                    MdiIcons.accountGroup,
                  ),
                  const SizedBox(height: 16),
                  _buildPeoplePreferenceSection(),
                  const SizedBox(height: 32),

                  // Mood Selection Section
                  _buildSectionTitle(
                    StringConstants.selectMood,
                    MdiIcons.emoticonOutline,
                  ),
                  const SizedBox(height: 16),
                  _buildMoodSelectionSection(),
                  const SizedBox(height: 32),

                  // Time Selection Section
                  _buildSectionTitle(
                    StringConstants.selectTime,
                    MdiIcons.clockOutline,
                  ),
                  const SizedBox(height: 16),
                  _buildTimeSelectionSection(),
                  const SizedBox(height: 40),

                  // Generate Button
                  _buildGenerateButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isGenerating) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int completedSteps = 0;
    if (selectedPeoplePreference != null) completedSteps++;
    if (selectedMoods.isNotEmpty) completedSteps++;
    if (selectedTimeOption != null) completedSteps++;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setup Progress',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completedSteps / 3,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$completedSteps/3 steps completed',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPeoplePreferenceSection() {
    return Column(
      children: AppConstants.peoplePreferences.map((preference) {
        final isSelected = selectedPeoplePreference == preference;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Add haptic feedback for better user experience
              HapticFeedback.lightImpact();
              
              // Immediate selection without delay
              setState(() {
                selectedPeoplePreference = preference;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPeopleIcon(preference),
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      preference,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodSelectionSection() {
    return PerformanceOptimizer.optimizedBuilder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select one or more moods that match your vibe:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.tripMoods.map((mood) {
              final isSelected = selectedMoods.contains(mood);
              return RepaintBoundary(
                child: CustomChip(
                  label: mood,
                  icon: _getMoodIcon(mood),
                  isSelected: isSelected,
                  onTap: () {
                    // Add haptic feedback for better user experience
                    HapticFeedback.lightImpact();
                    
                    // Immediate selection without delay for better UX
                    setState(() {
                      if (isSelected) {
                        selectedMoods.remove(mood);
                      } else {
                        selectedMoods.add(mood);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectionSection() {
    return Column(
      children: AppConstants.timeOptions.map((timeOption) {
        final isSelected = selectedTimeOption == timeOption;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Add haptic feedback for better user experience
              HapticFeedback.lightImpact();
              
              // Immediate selection without delay
              setState(() {
                selectedTimeOption = timeOption;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    MdiIcons.clockOutline,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      timeOption,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCitySelectionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedCity != null 
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Theme.of(context).dividerColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _selectCity,
        borderRadius: BorderRadius.circular(12),
        child: selectedCity == null
            ? Column(
                children: [
                  Icon(
                    MdiIcons.cityVariantOutline,
                    size: 48,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose your destination',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select from 80+ global destinations',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCity!.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedCity!.state} • ${selectedCity!.tier}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    MdiIcons.chevronRight,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectCity() async {
    final result = await Navigator.of(context).push<City>(
      MaterialPageRoute(
        builder: (context) => const CitySelectionScreen(),
      ),
    );
    
    if (result != null) {
      setState(() {
        selectedCity = result;
      });
    }
  }

  Widget _buildGenerateButton() {
    final canGenerate = selectedCity != null &&
        selectedPeoplePreference != null &&
        selectedMoods.isNotEmpty &&
        selectedTimeOption != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? _generateTrip : null,
        icon: Icon(
          MdiIcons.mapMarkerMultiple,
          color: Colors.white,
        ),
        label: Text(
          StringConstants.generateTripPlan,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canGenerate
              ? Theme.of(context).primaryColor
              : Colors.grey,
          elevation: canGenerate ? 8 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  IconData _getPeopleIcon(String preference) {
    return _peopleIcons[preference] ?? MdiIcons.account;
  }

  IconData _getMoodIcon(String mood) {
    return _moodIcons[mood] ?? MdiIcons.star;
  }

  Future<void> _generateTrip() async {
    if (selectedCity == null ||
        selectedPeoplePreference == null ||
        selectedMoods.isEmpty ||
        selectedTimeOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all steps before generating trip'),
        ),
      );
      return;
    }

    setState(() {
      isGenerating = true;
    });

    try {
      // Use API factory to get the appropriate service
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final cityService = apiProvider.cityService;
      final tripPlannerService = TripPlannerService();
      
      // Create trip parameters
      final tripPreferences = TripPreferences(
        destination: selectedCity!.name,
        duration: selectedTimeOption!.toLowerCase(),
        groupSize: _parseGroupSize(selectedPeoplePreference!),
        interests: selectedMoods,
        budget: TripBudget.medium, // Default budget
      );

      // Generate the trip using real algorithms
      final tripItinerary = await tripPlannerService.planTrip(
        city: selectedCity!,
        preferences: tripPreferences,
      );

      if (mounted) {
        // Convert to the existing Trip model format for compatibility
        final tripProvider = Provider.of<TripProvider>(context, listen: false);
        final trip = await tripProvider.generateTripFromItinerary(
          itinerary: tripItinerary,
          preferences: tripPreferences,
        );

        // Show interstitial ad before navigating to result screen (non-blocking)
        _adManager.showAdForEvent('trip_generated').catchError((error) {
          print('Ad failed to load: $error');
        });

        // Navigate immediately without waiting for ad
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripResultScreen(trip: trip),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate trip: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  int _parseGroupSize(String peoplePreference) {
    switch (peoplePreference.toLowerCase()) {
      case 'single':
        return 1;
      case 'couple':
        return 2;
      case 'group':
        return 4;
      default:
        return 2;
    }
  }
}
