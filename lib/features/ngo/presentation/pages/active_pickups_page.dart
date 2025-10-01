import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ngo_provider.dart';
import '../../../donor/data/models/donation_model.dart';
import 'donation_details_ngo_page.dart';

class ActivePickupsPage extends StatefulWidget {
  const ActivePickupsPage({super.key});

  @override
  State<ActivePickupsPage> createState() => _ActivePickupsPageState();
}

class _ActivePickupsPageState extends State<ActivePickupsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Pickups'),
      ),
      body: Consumer<NGOProvider>(
        builder: (context, provider, _) {
          if (provider.activePickups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active pickups',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accept donations to start collecting',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.activePickups.length,
            itemBuilder: (context, index) {
              final donation = provider.activePickups[index];
              return _buildPickupCard(context, provider, donation);
            },
          );
        },
      ),
    );
  }

  Widget _buildPickupCard(
    BuildContext context,
    NGOProvider provider,
    DonationModel donation,
  ) {
    final distance = provider.getDistanceTo(donation);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(donation.status.value),
              child: Icon(_getStatusIcon(donation.status.value), color: Colors.white),
            ),
            title: Text(
              donation.foodDetails.foodType.value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${donation.pickupLocation.city} • ${distance?.toStringAsFixed(1) ?? '?'} km',
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(donation.status.value).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(donation.status.value),
                    style: TextStyle(
                      color: _getStatusColor(donation.status.value),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _navigateToDonationDetails(context, provider, donation),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.people,
                        'Feeds ${donation.foodDetails.estimatedPeopleFed}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.location_on,
                        '${distance?.toStringAsFixed(1) ?? '?'} km',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActionButtons(context, provider, donation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    NGOProvider provider,
    DonationModel donation,
  ) {
    switch (donation.status.value) {
      case 'accepted':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(context, provider, donation.donationId, 'on_the_way'),
          icon: const Icon(Icons.directions_car),
          label: const Text('Mark On The Way'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      case 'on_the_way':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(context, provider, donation.donationId, 'reached'),
          icon: const Icon(Icons.check_circle),
          label: const Text('Mark Reached'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        );
      case 'reached':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(context, provider, donation.donationId, 'collected'),
          icon: const Icon(Icons.inventory),
          label: const Text('Mark Collected'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check;
      case 'on_the_way':
        return Icons.directions_car;
      case 'reached':
        return Icons.place;
      case 'collected':
        return Icons.inventory;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'on_the_way':
        return 'On The Way';
      case 'reached':
        return 'Reached';
      case 'collected':
        return 'Collected';
      default:
        return status;
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    NGOProvider provider,
    String donationId,
    String newStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Mark this donation as ${_getStatusText(newStatus)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      bool success = false;
      
      switch (newStatus) {
        case 'on_the_way':
          success = await provider.markOnTheWay(donationId);
          break;
        case 'reached':
          success = await provider.markReached(donationId);
          break;
        case 'collected':
          success = await provider.markCollected(donationId: donationId, notes: null);
          break;
      }

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to update status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToDonationDetails(
    BuildContext context,
    NGOProvider provider,
    DonationModel donation,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: DonationDetailsNGOPage(donation: donation),
        ),
      ),
    );
  }
}
