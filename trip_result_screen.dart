import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tripvisor/models/trip_models.dart';
import 'package:tripvisor/widgets/place_card.dart';
import 'package:tripvisor/services/share_service.dart';
import 'package:tripvisor/services/offline_storage_service.dart';
import 'package:tripvisor/services/navigation_service.dart';

class TripResultScreen extends StatefulWidget {
  final Trip trip;

  const TripResultScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripResultScreen> createState() => _TripResultScreenState();
}

class _TripResultScreenState extends State<TripResultScreen> {
  final OfflineStorageService _storageService = OfflineStorageService();
  bool _isSaved = false;
  bool _isCheckingSaved = true;

  @override
  void initState() {
    super.initState();
    _checkIfTripIsSaved();
  }

  Future<void> _checkIfTripIsSaved() async {
    final saved = await _storageService.isTripSaved(widget.trip.id);
    setState(() {
      _isSaved = saved;
      _isCheckingSaved = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Trip Plan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              await NavigationService.showShareOptions(context, widget.trip);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Trip Header
            _buildTripHeader(),
            
            // Trip Info
            _buildTripInfo(),
            
            // Places List
            _buildPlacesList(),
            
            // Action Buttons
            _buildActionButtons(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Icon(
            MdiIcons.checkCircle,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Trip Plan Ready!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.trip.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Duration',
                  widget.trip.duration,
                  MdiIcons.clockOutline,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'People',
                  widget.trip.peoplePreference,
                  MdiIcons.accountGroup,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Total Cost',
                  widget.trip.totalCost,
                  MdiIcons.currencyUsd,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Places',
                  '${widget.trip.places.length} stops',
                  MdiIcons.mapMarker,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Moods
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.trip.selectedMoods.map((mood) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  mood,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlacesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.mapMarkerMultiple,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Itinerary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.trip.places.length,
            itemBuilder: (context, index) {
              final place = widget.trip.places[index];
              return PlaceCard(
                place: place,
                stepNumber: index + 1,
                isLast: index == widget.trip.places.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Start Trip Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                await NavigationService.showNavigationOptions(context, widget.trip);
              },
              icon: Icon(MdiIcons.navigation),
              label: const Text(
                'Start Trip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Secondary Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  icon: Icon(MdiIcons.home),
                  label: const Text('Home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCheckingSaved ? null : () async {
                    if (_isSaved) {
                      // Show saved trips or navigate to saved trips screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trip is already saved offline!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      // Save the trip
                      final success = await _storageService.saveTripOffline(widget.trip);
                      if (success) {
                        setState(() {
                          _isSaved = true;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Trip saved offline successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save trip offline'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: _isCheckingSaved 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isSaved ? MdiIcons.checkCircle : MdiIcons.download),
                  label: Text(_isSaved ? 'Saved' : 'Save Offline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isSaved ? Colors.green : Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: _isSaved ? Colors.green : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
