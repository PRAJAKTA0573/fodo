import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/donation_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'create_donation_page.dart';
import 'donation_history_page.dart';
import 'impact_dashboard_page.dart';
import 'donation_details_page.dart';
import 'package:intl/intl.dart';

/// Donor Dashboard - Main home screen for donors
class DonorDashboardPage extends StatefulWidget {
  const DonorDashboardPage({super.key});

  @override
  State<DonorDashboardPage> createState() => _DonorDashboardPageState();
}

class _DonorDashboardPageState extends State<DonorDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final donationProvider = context.read<DonationProvider>();

    if (authProvider.currentUser != null) {
      donationProvider.loadDonations(authProvider.currentUser!.userId);
      donationProvider.loadStatistics(authProvider.currentUser!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FODO - Donor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImpactDashboardPage(),
                ),
              );
            },
            tooltip: 'My Impact',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: donationProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(authProvider),
                      const SizedBox(height: 24),

                      // Statistics Cards
                      _buildStatisticsSection(donationProvider),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(context),
                      const SizedBox(height: 24),

                      // Active Donations
                      _buildActiveDonationsSection(donationProvider),
                      const SizedBox(height: 24),

                      // Recent Donations
                      _buildRecentDonationsSection(donationProvider),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateDonationPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Donation'),
      ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.person,
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
                    'Welcome back!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.currentUser?.profileData.fullName ?? 'Donor',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(DonationProvider donationProvider) {
    final stats = donationProvider.statistics ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Donations',
            value: stats['total']?.toString() ?? '0',
            icon: Icons.local_dining,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'People Fed',
            value: stats['totalPeopleFed']?.toString() ?? '0',
            icon: Icons.people,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                title: 'Donate Food',
                icon: Icons.add_circle_outline,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateDonationPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                title: 'My Donations',
                icon: Icons.history,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonationHistoryPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDonationsSection(DonationProvider donationProvider) {
    final activeDonations = donationProvider.activeDonations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Donations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (activeDonations.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonationHistoryPage(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeDonations.isEmpty)
          _buildEmptyState('No active donations')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeDonations.length > 3 ? 3 : activeDonations.length,
            itemBuilder: (context, index) {
              return _buildDonationCard(activeDonations[index]);
            },
          ),
      ],
    );
  }

  Widget _buildRecentDonationsSection(DonationProvider donationProvider) {
    final recentDonations = donationProvider.donations.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Donations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (recentDonations.isEmpty)
          _buildEmptyState('No donations yet')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentDonations.length,
            itemBuilder: (context, index) {
              return _buildDonationCard(recentDonations[index]);
            },
          ),
      ],
    );
  }

  Widget _buildDonationCard(DonationModel donation) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getStatusColor(donation.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant,
            color: _getStatusColor(donation.status),
          ),
        ),
        title: Text(
          donation.foodDetails.foodType.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              donation.foodDetails.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(donation.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            donation.status.displayName,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor(donation.status).withOpacity(0.1),
          labelStyle: TextStyle(
            color: _getStatusColor(donation.status),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailsPage(
                donationId: donation.donationId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.created:
      case DonationStatus.visible:
        return Colors.blue;
      case DonationStatus.accepted:
      case DonationStatus.inTransit:
        return Colors.orange;
      case DonationStatus.collected:
      case DonationStatus.distributed:
        return Colors.purple;
      case DonationStatus.completed:
        return Colors.green;
      case DonationStatus.cancelled:
        return Colors.red;
      case DonationStatus.expired:
        return Colors.grey;
    }
  }
}
