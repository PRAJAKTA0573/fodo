import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// Impact Dashboard Page - View donation statistics and achievements
class ImpactDashboardPage extends StatefulWidget {
  const ImpactDashboardPage({super.key});

  @override
  State<ImpactDashboardPage> createState() => _ImpactDashboardPageState();
}

class _ImpactDashboardPageState extends State<ImpactDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final donationProvider = context.read<DonationProvider>();

    if (authProvider.currentUser != null) {
      donationProvider.loadStatistics(authProvider.currentUser!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final stats = donationProvider.statistics ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Impact'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: donationProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Stats
                    _buildHeroSection(stats),
                    const SizedBox(height: 24),

                    // Statistics Grid
                    _buildStatsGrid(stats),
                    const SizedBox(height: 24),

                    // Achievements
                    _buildAchievementsSection(stats),
                    const SizedBox(height: 24),

                    // Monthly Breakdown
                    _buildMonthlyBreakdown(donationProvider),
                    const SizedBox(height: 24),

                    // Impact Message
                    _buildImpactMessage(stats),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroSection(Map<String, int> stats) {
    final peopleFed = stats['totalPeopleFed'] ?? 0;

    return Card(
      elevation: 4,
      color: Colors.green[700],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              NumberFormat('#,###').format(peopleFed),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'People Fed',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your generosity is making a difference!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donation Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Donations',
              stats['total']?.toString() ?? '0',
              Icons.local_dining,
              Colors.blue,
            ),
            _buildStatCard(
              'Completed',
              stats['completed']?.toString() ?? '0',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Active',
              stats['active']?.toString() ?? '0',
              Icons.schedule,
              Colors.orange,
            ),
            _buildStatCard(
              'Cancelled',
              stats['cancelled']?.toString() ?? '0',
              Icons.cancel,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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

  Widget _buildAchievementsSection(Map<String, int> stats) {
    final total = stats['total'] ?? 0;
    final peopleFed = stats['totalPeopleFed'] ?? 0;

    final achievements = _getAchievements(total, peopleFed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  List<Map<String, dynamic>> _getAchievements(int total, int peopleFed) {
    final achievements = <Map<String, dynamic>>[];

    // Donation milestones
    if (total >= 1) {
      achievements.add({
        'title': 'First Step',
        'description': 'Made your first donation',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'unlocked': true,
      });
    }
    if (total >= 5) {
      achievements.add({
        'title': 'Generous Heart',
        'description': 'Completed 5 donations',
        'icon': Icons.favorite,
        'color': Colors.red,
        'unlocked': true,
      });
    }
    if (total >= 10) {
      achievements.add({
        'title': 'Change Maker',
        'description': 'Completed 10 donations',
        'icon': Icons.star,
        'color': Colors.purple,
        'unlocked': true,
      });
    }
    if (total >= 25) {
      achievements.add({
        'title': 'Community Hero',
        'description': 'Completed 25 donations',
        'icon': Icons.military_tech,
        'color': Colors.blue,
        'unlocked': true,
      });
    } else if (total >= 10) {
      achievements.add({
        'title': 'Community Hero',
        'description': 'Complete 25 donations to unlock',
        'icon': Icons.lock,
        'color': Colors.grey,
        'unlocked': false,
      });
    }

    // People fed milestones
    if (peopleFed >= 10) {
      achievements.add({
        'title': 'Meal Provider',
        'description': 'Fed 10+ people',
        'icon': Icons.restaurant,
        'color': Colors.green,
        'unlocked': true,
      });
    }
    if (peopleFed >= 50) {
      achievements.add({
        'title': 'Hunger Fighter',
        'description': 'Fed 50+ people',
        'icon': Icons.dining,
        'color': Colors.teal,
        'unlocked': true,
      });
    }
    if (peopleFed >= 100) {
      achievements.add({
        'title': 'Impact Champion',
        'description': 'Fed 100+ people',
        'icon': Icons.celebration,
        'color': Colors.orange,
        'unlocked': true,
      });
    }

    return achievements;
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: achievement['color'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement['icon'],
            color: achievement['color'],
          ),
        ),
        title: Text(
          achievement['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: achievement['unlocked'] ? null : Colors.grey,
          ),
        ),
        subtitle: Text(achievement['description']),
        trailing: achievement['unlocked']
            ? Icon(Icons.check_circle, color: achievement['color'])
            : null,
      ),
    );
  }

  Widget _buildMonthlyBreakdown(DonationProvider provider) {
    final donations = provider.donations;
    final now = DateTime.now();
    
    // Group by month
    final monthlyData = <String, int>{};
    for (var donation in donations) {
      if (donation.status.value == 'completed') {
        final monthKey = DateFormat('MMM yyyy').format(donation.createdAt);
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
      }
    }

    final sortedMonths = monthlyData.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (sortedMonths.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No completed donations yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...sortedMonths.take(6).map((month) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_month, color: Colors.blue[700]),
                ),
                title: Text(month),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${monthlyData[month]} donation${monthlyData[month]! > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildImpactMessage(Map<String, int> stats) {
    final peopleFed = stats['totalPeopleFed'] ?? 0;
    final meals = peopleFed * 3; // Assuming 3 meals per person

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.eco, size: 48, color: Colors.blue[700]),
            const SizedBox(height: 16),
            const Text(
              'Your Environmental Impact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'By donating food, you\'ve helped prevent food waste and provided approximately ${NumberFormat('#,###').format(meals)} meals!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildImpactStat(Icons.delete_outline, 'Waste Reduced', '${peopleFed * 2} kg'),
                _buildImpactStat(Icons.cloud_outlined, 'CO₂ Saved', '${peopleFed * 5} kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
