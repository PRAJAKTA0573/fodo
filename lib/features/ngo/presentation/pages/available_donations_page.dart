import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ngo_provider.dart';
import '../../../donor/data/models/donation_model.dart';
import 'donation_details_ngo_page.dart';

class AvailableDonationsPage extends StatefulWidget {
  const AvailableDonationsPage({super.key});

  @override
  State<AvailableDonationsPage> createState() => _AvailableDonationsPageState();
}

class _AvailableDonationsPageState extends State<AvailableDonationsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search donations...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<NGOProvider>().updateSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    context.read<NGOProvider>().updateSearchQuery(value);
                  },
                ),
              ),
              _buildFilterBar(),
            ],
          ),
        ),
      ),
      body: Consumer<NGOProvider>(
        builder: (context, provider, _) {
          final donations = provider.availableDonations;

          if (donations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No donations available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              return _buildDonationCard(context, provider, donations[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterDialog(context),
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Consumer<NGOProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                'Sort: ${_getSortLabel(provider.sortBy)}',
                Icons.sort,
                () => _showSortDialog(context),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Distance: ${provider.maxDistance.toInt()}km',
                Icons.location_on,
                () => _showDistanceDialog(context),
              ),
              const SizedBox(width: 8),
              if (provider.selectedFoodType != 'All')
                _buildFilterChip(
                  provider.selectedFoodType,
                  Icons.restaurant,
                  () => provider.updateFoodTypeFilter('All'),
                  isSelected: true,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onPressed: onTap,
      backgroundColor: isSelected ? Colors.blue.shade100 : null,
    );
  }

  Widget _buildDonationCard(
    BuildContext context,
    NGOProvider provider,
    DonationModel donation,
  ) {
    final distance = provider.getDistanceTo(donation);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDonationDetails(context, provider, donation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.foodDetails.foodType.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          donation.foodDetails.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    Icons.people,
                    'Feeds ${donation.foodDetails.estimatedPeopleFed}',
                    Colors.green,
                  ),
                  _buildInfoChip(
                    Icons.scale,
                    '${donation.foodDetails.quantity.value.toStringAsFixed(0)} ${donation.foodDetails.quantity.unit.value}',
                    Colors.purple,
                  ),
                  if (donation.foodDetails.isVegetarian)
                    _buildInfoChip(
                      Icons.eco,
                      'Veg',
                      Colors.green,
                    ),
                  if (donation.foodDetails.isPackaged)
                    _buildInfoChip(
                      Icons.inventory_2,
                      'Packaged',
                      Colors.blue,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${donation.pickupLocation.city}, ${donation.pickupLocation.state}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(donation.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'distance':
        return 'Distance';
      case 'time':
        return 'Time';
      case 'quantity':
        return 'Quantity';
      default:
        return sortBy;
    }
  }

  void _showSortDialog(BuildContext context) {
    final provider = context.read<NGOProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Distance (nearest first)'),
              value: 'distance',
              groupValue: provider.sortBy,
              onChanged: (value) {
                if (value != null) provider.updateSortBy(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Time (newest first)'),
              value: 'time',
              groupValue: provider.sortBy,
              onChanged: (value) {
                if (value != null) provider.updateSortBy(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Quantity (largest first)'),
              value: 'quantity',
              groupValue: provider.sortBy,
              onChanged: (value) {
                if (value != null) provider.updateSortBy(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDistanceDialog(BuildContext context) {
    final provider = context.read<NGOProvider>();
    double currentDistance = provider.maxDistance;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Maximum Distance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${currentDistance.toInt()} km'),
              Slider(
                value: currentDistance,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${currentDistance.toInt()} km',
                onChanged: (value) {
                  setState(() => currentDistance = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.updateMaxDistance(currentDistance);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<NGOProvider>(
        builder: (context, provider, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Food Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'All',
                  'Cooked Food',
                  'Packaged Food',
                  'Fruits & Vegetables',
                  'Bakery Items',
                ].map((type) {
                  final isSelected = provider.selectedFoodType == type;
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      provider.updateFoodTypeFilter(type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
