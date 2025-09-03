import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tripvisor/models/trip_models.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkCompleted;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.onDelete,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Image Header
              _buildTripHeader(context),
              
              // Trip Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Title and Status
                    _buildTitleRow(context),
                    const SizedBox(height: 8),
                    
                    // Trip Details
                    _buildTripDetails(context),
                    const SizedBox(height: 12),
                    
                    // Trip Stats
                    _buildTripStats(context),
                    const SizedBox(height: 12),
                    
                    // Moods/Tags
                    _buildMoodTags(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripHeader(BuildContext context) {
    final firstPlace = trip.places.isNotEmpty ? trip.places.first : null;
    
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
            ),
          ),
          child: firstPlace != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      firstPlace.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: firstPlace.imageUrl,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                child: Center(
                                  child: Icon(
                                    MdiIcons.imageOff,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 48,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                child: Center(
                                  child: Icon(
                                    MdiIcons.imageOff,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 48,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 150,
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  MdiIcons.imageOff,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 48,
                                ),
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Icon(
                    MdiIcons.mapMarkerMultiple,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
        ),
        
        // Status Badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trip.status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Action Menu
        if (onDelete != null || (onMarkCompleted != null && trip.status == 'planned'))
          Positioned(
            top: 12,
            left: 12,
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              ),
              itemBuilder: (context) => [
                if (onMarkCompleted != null && trip.status == 'planned')
                  const PopupMenuItem<String>(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Mark as Completed'),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete Trip'),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'complete':
                    onMarkCompleted?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            trip.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          _getStatusIcon(),
          color: _getStatusColor(),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildTripDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.calendar,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(trip.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              MdiIcons.accountGroup,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              trip.peoplePreference,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripStats(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          context,
          MdiIcons.clockOutline,
          trip.duration,
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          context,
          MdiIcons.mapMarker,
          '${trip.places.length} places',
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          context,
          MdiIcons.currencyUsd,
          trip.totalCost,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTags(BuildContext context) {
    final displayMoods = trip.selectedMoods.take(3).toList();
    final remainingCount = trip.selectedMoods.length - 3;
    
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...displayMoods.map((mood) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              mood,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount more',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (trip.status) {
      case 'completed':
        return MdiIcons.checkCircle;
      case 'planned':
        return MdiIcons.clockOutline;
      case 'cancelled':
        return MdiIcons.cancel;
      default:
        return MdiIcons.mapMarker;
    }
  }

  Color _getStatusColor() {
    switch (trip.status) {
      case 'completed':
        return Colors.green;
      case 'planned':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
