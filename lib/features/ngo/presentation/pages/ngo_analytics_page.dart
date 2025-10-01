import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ngo_provider.dart';

class NGOAnalyticsPage extends StatelessWidget {
  const NGOAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Consumer<NGOProvider>(
        builder: (context, provider, _) {
          if (provider.ngo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final ngo = provider.ngo!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Statistics
                const Text(
                  'Overall Impact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOverallStats(ngo.statistics),
                const SizedBox(height: 32),

                // Current Status
                const Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCurrentStatus(provider),
                const SizedBox(height: 32),

                // Performance Metrics
                const Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPerformanceCard(ngo.statistics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStats(dynamic statistics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Collections',
                '${statistics.totalCollections ?? 0}',
                Icons.history,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'People Fed',
                _formatNumber(statistics.totalPeopleFed ?? 0),
                Icons.people,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completed',
                '${statistics.completedCollections ?? 0}',
                Icons.check_circle,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Rating',
                '${statistics.rating?.toStringAsFixed(1) ?? '0.0'} ⭐',
                Icons.star,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(NGOProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusRow(
              'Active Pickups',
              provider.activePickupsCount.toString(),
              Icons.local_shipping,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildStatusRow(
              'Available Nearby',
              provider.availableCount.toString(),
              Icons.restaurant,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(dynamic statistics) {
    final totalCollections = statistics.totalCollections ?? 0;
    final completedCollections = statistics.completedCollections ?? 0;
    final completionRate = totalCollections > 0 
        ? (completedCollections / totalCollections * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Completion Rate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$completionRate%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: totalCollections > 0 ? completedCollections / totalCollections : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.green[700]),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text(
              '$completedCollections of $totalCollections collections completed',
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
