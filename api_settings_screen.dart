import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class ApiSettingsScreen extends StatelessWidget {
  const ApiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configuration'),
        elevation: 0,
      ),
      body: Consumer<ApiProvider>(
        builder: (context, apiProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentStatusCard(apiProvider),
                const SizedBox(height: 24),
                _buildApiModeSelector(context, apiProvider),
                const SizedBox(height: 24),
                _buildApiComparison(),
                const SizedBox(height: 24),
                _buildFeaturesCard(apiProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatusCard(ApiProvider apiProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  apiProvider.useFreeApis ? Icons.free_breakfast : Icons.star,
                  color: apiProvider.useFreeApis ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current: ${apiProvider.currentApiMode}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Provider: ${apiProvider.currentProvider}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Cost: ${apiProvider.costInfo}',
              style: TextStyle(
                fontSize: 16,
                color: apiProvider.useFreeApis ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiModeSelector(BuildContext context, ApiProvider apiProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select API Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: apiProvider.useFreeApis ? null : () {
                      apiProvider.setFreeApis(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Switched to Free APIs - No cost, OpenStreetMap data'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.free_breakfast),
                    label: const Text('Free APIs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: apiProvider.useFreeApis ? Colors.green : null,
                      foregroundColor: apiProvider.useFreeApis ? Colors.white : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !apiProvider.useFreeApis ? null : () {
                      _showGoogleApiWarning(context, apiProvider);
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Google APIs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !apiProvider.useFreeApis ? Colors.blue : null,
                      foregroundColor: !apiProvider.useFreeApis ? Colors.white : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              children: [
                const TableRow(
                  children: [
                    Text('Feature', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Free APIs', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Google APIs', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const TableRow(children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)]),
                _buildTableRow('Monthly Cost', '\$0', '\$200-500'),
                _buildTableRow('Setup Time', '0 minutes', '30+ minutes'),
                _buildTableRow('API Keys', 'None required', 'Required + Billing'),
                _buildTableRow('Cities Coverage', '100+ Indian', 'Global'),
                _buildTableRow('Data Source', 'OpenStreetMap', 'Google'),
                _buildTableRow('Place Details', 'Basic info', 'Ratings, reviews, photos'),
                _buildTableRow('Routing', 'OSRM (free)', 'Google Directions'),
                _buildTableRow('Map Quality', 'Good', 'Excellent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String feature, String free, String google) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(feature),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(free, style: const TextStyle(color: Colors.green)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(google, style: const TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildFeaturesCard(ApiProvider apiProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${apiProvider.currentApiMode} Features',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...apiProvider.currentFeatures.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: apiProvider.useFreeApis ? Colors.green : Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showGoogleApiWarning(BuildContext context, ApiProvider apiProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Switch to Google APIs?'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Google APIs provide premium features but require:'),
              SizedBox(height: 12),
              Text('• Valid API keys'),
              Text('• Billing account setup'),
              Text('• \$200-500/month estimated cost'),
              Text('• Google Cloud Console configuration'),
              SizedBox(height: 12),
              Text('Make sure you have completed the Google API setup first.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                apiProvider.setFreeApis(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Switched to Google APIs - Premium features enabled'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Text('Switch to Google APIs'),
            ),
          ],
        );
      },
    );
  }
}
