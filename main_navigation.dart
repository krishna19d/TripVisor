import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tripvisor/screens/dashboard_screen.dart';
import 'package:tripvisor/screens/my_trips_screen.dart';
import 'package:tripvisor/screens/profile_screen.dart';
import 'package:tripvisor/utils/constants.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MyTripsScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: MdiIcons.viewDashboard,
      label: StringConstants.dashboard,
    ),
    NavigationItem(
      icon: MdiIcons.mapMarkerMultiple,
      label: StringConstants.myTrip,
    ),
    NavigationItem(
      icon: MdiIcons.account,
      label: StringConstants.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AnimationConstants.normalAnimation,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: _navigationItems.map((item) {
            final index = _navigationItems.indexOf(item);
            final isSelected = index == _currentIndex;
            
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: AnimationConstants.fastAnimation,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.label,
  });
}
