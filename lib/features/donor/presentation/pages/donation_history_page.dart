import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import '../../data/models/donation_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'donation_details_page.dart';
import 'package:intl/intl.dart';

/// Donation History Page - View all donations with filters
class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DonationModel> _getFilteredDonations(List<DonationModel> donations) {
    var filtered = donations;

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((d) => d.status.value == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        return d.foodDetails.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            d.foodDetails.foodType.displayName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            d.pickupLocation.city
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final donations = _getFilteredDonations(donationProvider.donations);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Donations'),
              ),
              const PopupMenuItem(
                value: 'created',
                child: Text('Created'),
              ),
              const PopupMenuItem(
                value: 'visible',
                child: Text('Available'),
              ),
              const PopupMenuItem(
                value: 'accepted',
                child: Text('Accepted'),
              ),
              const PopupMenuItem(
                value: 'inTransit',
                child: Text('In Transit'),
              ),
              const PopupMenuItem(
                value: 'collected',
                child: Text('Collected'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Text('Cancelled'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search donations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filter Chip
          if (_selectedFilter != 'all')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      'Filter: ${DonationStatus.fromString(_selectedFilter).displayName}',
                    ),
                    onDeleted: () {
                      setState(() => _selectedFilter = 'all');
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${donations.length} result${donations.length != 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Donations List
          Expanded(
            child: donationProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : donations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Reload donations
                          final authProvider = context.read();
                          if (authProvider.currentUser != null) {
                            await donationProvider.loadDonations(
                              authProvider.currentUser!.userId,
                            );
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: donations.length,
                          itemBuilder: (context, index) {
                            return _buildDonationCard(donations[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(DonationModel donation) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _getStatusColor(donation.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (AppConstants.imagesEnabled && donation.foodDetails.photos.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              donation.foodDetails.photos.first.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.restaurant,
                                  size: 32,
                                  color: _getStatusColor(donation.status),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.restaurant,
                            size: 32,
                            color: _getStatusColor(donation.status),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                donation.foodDetails.foodType.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                donation.status.displayName,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor:
                                  _getStatusColor(donation.status).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: _getStatusColor(donation.status),
                                fontWeight: FontWeight.bold,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          donation.foodDetails.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${donation.foodDetails.estimatedPeopleFed} people',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                donation.pickupLocation.city,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(donation.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // NGO Info (if accepted)
              if (donation.ngoInfo != null) ...[
                const Divider(height: 16),
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Accepted by ${donation.ngoInfo!.ngoName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? Icons.search_off
                : Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'No donations found'
                : 'No donations yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try adjusting your filters'
                : 'Start creating donations to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
