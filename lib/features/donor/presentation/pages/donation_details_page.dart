import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/donation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/donation_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Donation Details Page - View full donation information
class DonationDetailsPage extends StatefulWidget {
  final String donationId;

  const DonationDetailsPage({
    super.key,
    required this.donationId,
  });

  @override
  State<DonationDetailsPage> createState() => _DonationDetailsPageState();
}

class _DonationDetailsPageState extends State<DonationDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadDonation();
  }

  void _loadDonation() {
    final donationProvider = context.read<DonationProvider>();
    donationProvider.loadDonation(widget.donationId);
    
    // Listen to real-time updates
    donationProvider.listenToDonation(widget.donationId);
  }

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final donation = donationProvider.currentDonation;

    if (donationProvider.isLoading || donation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donation Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        actions: [
          if (_canCancel(donation.status))
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => _showCancelDialog(donation),
              tooltip: 'Cancel Donation',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Gallery
            if (donation.foodDetails.photos.isNotEmpty)
              _buildPhotoGallery(donation.foodDetails.photos),

            // Status Banner
            _buildStatusBanner(donation),

            // Food Details Section
            _buildSection(
              'Food Details',
              _buildFoodDetails(donation.foodDetails),
            ),

            // Pickup Location Section
            _buildSection(
              'Pickup Location',
              _buildLocationDetails(donation.pickupLocation),
            ),

            // NGO Details (if accepted)
            if (donation.ngoInfo != null)
              _buildSection(
                'Accepted By',
                _buildNgoDetails(donation.ngoInfo!),
              ),

            // Timeline Section
            _buildSection(
              'Donation Timeline',
              _buildTimeline(donation),
            ),

            // Special Instructions
            if (donation.specialInstructions != null)
              _buildSection(
                'Special Instructions',
                Text(donation.specialInstructions!),
              ),

            // Rating Section (if completed and not rated)
            if (donation.status == DonationStatus.completed &&
                donation.rating == null)
              _buildRatingPrompt(donation),

            // Show rating if exists
            if (donation.rating != null)
              _buildSection(
                'Your Rating',
                _buildRatingDisplay(donation.rating!),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(donation),
    );
  }

  Widget _buildPhotoGallery(List<PhotoInfo> photos) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showFullScreenImage(context, photos, index),
            child: Image.network(
              photos[index].url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 64),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(DonationModel donation) {
    final status = donation.status;
    final color = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: color.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(status),
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildFoodDetails(FoodDetails food) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Food Type', food.foodType.displayName),
            _buildDetailRow('Description', food.description),
            _buildDetailRow(
              'Quantity',
              '${food.quantity.value.toStringAsFixed(0)} ${food.quantity.unit.displayName}',
            ),
            _buildDetailRow(
              'Estimated People Fed',
              food.estimatedPeopleFed.toString(),
            ),
            _buildDetailRow('Best Before', dateFormat.format(food.bestBefore)),
            _buildDetailRow('Vegetarian', food.isVegetarian ? 'Yes' : 'No'),
            _buildDetailRow('Packaged', food.isPackaged ? 'Yes' : 'No'),
            if (food.allergens.isNotEmpty)
              _buildDetailRow('Allergens', food.allergens.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetails(PickupLocation location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.fullAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${location.city}, ${location.state} - ${location.pincode}'),
                      if (location.landmark != null) ...[
                        const SizedBox(height: 8),
                        Text('Landmark: ${location.landmark}'),
                      ],
                      if (location.instructions != null) ...[
                        const SizedBox(height: 8),
                        Text('Instructions: ${location.instructions}'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNgoDetails(NgoInfo ngo) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.business, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ngo.ngoName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Contact: ${ngo.contactPerson}'),
                      Text('Phone: ${ngo.contactPhone}'),
                    ],
                  ),
                ),
              ],
            ),
            if (ngo.estimatedPickupTime != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Est. Pickup: ${dateFormat.format(ngo.estimatedPickupTime!)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(DonationModel donation) {
    final timeline = donation.timeline;
    final dateFormat = DateFormat('MMM dd, yyyy\nhh:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTimelineItem(
              'Created',
              timeline.createdAt,
              dateFormat,
              true,
              Icons.add_circle,
            ),
            if (timeline.visibleAt != null)
              _buildTimelineItem(
                'Made Visible',
                timeline.visibleAt!,
                dateFormat,
                true,
                Icons.visibility,
              ),
            if (timeline.acceptedAt != null)
              _buildTimelineItem(
                'Accepted',
                timeline.acceptedAt!,
                dateFormat,
                true,
                Icons.check_circle,
              ),
            if (timeline.inTransitAt != null)
              _buildTimelineItem(
                'In Transit',
                timeline.inTransitAt!,
                dateFormat,
                true,
                Icons.local_shipping,
              ),
            if (timeline.collectedAt != null)
              _buildTimelineItem(
                'Collected',
                timeline.collectedAt!,
                dateFormat,
                true,
                Icons.done_all,
              ),
            if (timeline.distributedAt != null)
              _buildTimelineItem(
                'Distributed',
                timeline.distributedAt!,
                dateFormat,
                true,
                Icons.volunteer_activism,
              ),
            if (timeline.completedAt != null)
              _buildTimelineItem(
                'Completed',
                timeline.completedAt!,
                dateFormat,
                true,
                Icons.celebration,
              ),
            if (timeline.cancelledAt != null)
              _buildTimelineItem(
                'Cancelled',
                timeline.cancelledAt!,
                dateFormat,
                true,
                Icons.cancel,
                isError: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    DateTime timestamp,
    DateFormat format,
    bool isCompleted,
    IconData icon, {
    bool isError = false,
  }) {
    final color = isError ? Colors.red : (isCompleted ? Colors.green : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  format.format(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingPrompt(DonationModel donation) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.star, size: 48, color: Colors.green[700]),
          const SizedBox(height: 12),
          Text(
            'Rate Your Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help others by rating this NGO',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showRatingDialog(donation),
            icon: const Icon(Icons.rate_review),
            label: const Text('Rate Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDisplay(Rating rating) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  );
                }),
                const SizedBox(width: 12),
                Text(
                  rating.rating.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (rating.comment != null) ...[
              const SizedBox(height: 12),
              Text(rating.comment!),
            ],
            const SizedBox(height: 8),
            Text(
              'Rated on ${dateFormat.format(rating.ratedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomActions(DonationModel donation) {
    if (donation.status == DonationStatus.cancelled ||
        donation.status == DonationStatus.expired) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_canCancel(donation.status))
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(donation),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            if (_canCancel(donation.status)) const SizedBox(width: 12),
            if (donation.status == DonationStatus.completed &&
                donation.rating == null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRatingDialog(donation),
                  icon: const Icon(Icons.star),
                  label: const Text('Rate NGO'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canCancel(DonationStatus status) {
    return ![
      DonationStatus.collected,
      DonationStatus.distributed,
      DonationStatus.completed,
      DonationStatus.cancelled,
      DonationStatus.expired,
    ].contains(status);
  }

  void _showCancelDialog(DonationModel donation) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Donation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this donation?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'Please provide a reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Donation'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final donationProvider = context.read<DonationProvider>();
              final success = await donationProvider.cancelDonation(
                donation.donationId,
                reasonController.text.trim(),
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Donation cancelled'
                          : donationProvider.errorMessage ?? 'Failed to cancel',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Donation'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(DonationModel donation) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate NGO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                donation.ngoInfo?.ngoName ?? 'NGO',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() => rating = (index + 1).toDouble());
                    },
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (Optional)',
                  hintText: 'Share your experience',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final donationProvider = context.read<DonationProvider>();
                final success = await donationProvider.rateDonation(
                  donation.donationId,
                  rating,
                  commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Thank you for your feedback!'
                            : donationProvider.errorMessage ?? 'Failed to submit rating',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    List<PhotoInfo> photos,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('${initialIndex + 1} / ${photos.length}'),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    photos[index].url,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
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

  IconData _getStatusIcon(DonationStatus status) {
    switch (status) {
      case DonationStatus.created:
        return Icons.add_circle;
      case DonationStatus.visible:
        return Icons.visibility;
      case DonationStatus.accepted:
        return Icons.check_circle;
      case DonationStatus.inTransit:
        return Icons.local_shipping;
      case DonationStatus.collected:
        return Icons.done_all;
      case DonationStatus.distributed:
        return Icons.volunteer_activism;
      case DonationStatus.completed:
        return Icons.celebration;
      case DonationStatus.cancelled:
        return Icons.cancel;
      case DonationStatus.expired:
        return Icons.timer_off;
    }
  }
}
