import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ngo_provider.dart';
import 'available_donations_page.dart';
import 'active_pickups_page.dart';
import 'collection_history_page.dart';
import 'ngo_analytics_page.dart';

class NGODashboardPage extends StatefulWidget {
  const NGODashboardPage({super.key});

  @override
  State<NGODashboardPage> createState() => _NGODashboardPageState();
}

class _NGODashboardPageState extends State<NGODashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<NGOProvider>();
    await provider.loadCollectionHistory();
  }

  Future<void> _refreshData() async {
    final provider = context.read<NGOProvider>();
    await provider.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<NGOProvider>(),
                    child: const NGOAnalyticsPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer<NGOProvider>(
        builder: (context, provider, _) {
          if (provider.ngo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(provider),
                  const SizedBox(height: 24),

                  // Statistics Cards
                  _buildStatisticsSection(provider),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context, provider),
                  const SizedBox(height: 24),

                  // Active Pickups Section
                  _buildSectionHeader(
                    'Active Pickups',
                    '${provider.activePickupsCount} active',
                    () => _navigateToActivePickups(context, provider),
                  ),
                  const SizedBox(height: 12),
                  _buildActivePickupsList(provider),
                  const SizedBox(height: 24),

                  // Available Donations Section
                  _buildSectionHeader(
                    'Available Nearby',
                    '${provider.availableCount} available',
                    () => _navigateToAvailableDonations(context, provider),
                  ),
                  const SizedBox(height: 12),
                  _buildAvailableDonationsPreview(provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAvailableDonations(
          context,
          context.read<NGOProvider>(),
        ),
        icon: const Icon(Icons.search),
        label: const Text('Find Donations'),
      ),
    );
  }

  Widget _buildWelcomeSection(NGOProvider provider) {
    final ngo = provider.ngo!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.shade100,
              child: Icon(
                Icons.volunteer_activism,
                size: 32,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ngo.ngoName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ngo.location.city,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (ngo.verification.status == 'verified') ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified NGO',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(NGOProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Collections',
            provider.totalCollections.toString(),
            Icons.history,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'People Fed',
            _formatNumber(provider.totalPeopleFed),
            Icons.people,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, NGOProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Available\nDonations',
            Icons.restaurant,
            Colors.orange,
            () => _navigateToAvailableDonations(context, provider),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Active\nPickups',
            Icons.local_shipping,
            Colors.blue,
            () => _navigateToActivePickups(context, provider),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Collection\nHistory',
            Icons.history,
            Colors.purple,
            () => _navigateToCollectionHistory(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildActivePickupsList(NGOProvider provider) {
    if (provider.activePickups.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No active pickups',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pickups = provider.activePickups.take(3).toList();
    return Column(
      children: pickups.map((donation) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(donation.status.value),
              child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
            ),
            title: Text(
              donation.foodDetails.foodType.value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${donation.pickupLocation.city} • ${_getStatusText(donation.status.value)}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              'Feeds ${donation.foodDetails.estimatedPeopleFed}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailableDonationsPreview(NGOProvider provider) {
    if (provider.availableDonations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No donations available nearby',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final donations = provider.availableDonations.take(3).toList();
    return Column(
      children: donations.map((donation) {
        final distance = provider.getDistanceTo(donation);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Icon(Icons.restaurant, color: Colors.orange.shade700, size: 20),
            ),
            title: Text(
              donation.foodDetails.foodType.value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${donation.pickupLocation.city} • ${distance?.toStringAsFixed(1) ?? '?'} km',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              'Feeds ${donation.foodDetails.estimatedPeopleFed}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.blue;
      case 'on_the_way':
        return Colors.orange;
      case 'reached':
        return Colors.purple;
      case 'collected':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'on_the_way':
        return 'On the way';
      case 'reached':
        return 'Reached location';
      case 'collected':
        return 'Collected';
      default:
        return status;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _navigateToAvailableDonations(BuildContext context, NGOProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const AvailableDonationsPage(),
        ),
      ),
    );
  }

  void _navigateToActivePickups(BuildContext context, NGOProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const ActivePickupsPage(),
        ),
      ),
    );
  }

  void _navigateToCollectionHistory(BuildContext context, NGOProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const CollectionHistoryPage(),
        ),
      ),
    );
  }
}
