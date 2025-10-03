import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/ngo_provider.dart';
import '../../../donor/data/models/donation_model.dart';
import '../../../../core/constants/app_constants.dart';

class DonationDetailsNGOPage extends StatefulWidget {
  final DonationModel donation;

  const DonationDetailsNGOPage({super.key, required this.donation});

  @override
  State<DonationDetailsNGOPage> createState() => _DonationDetailsNGOPageState();
}

class _DonationDetailsNGOPageState extends State<DonationDetailsNGOPage> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NGOProvider>();
    final distance = provider.getDistanceTo(widget.donation);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions),
            onPressed: () => _openMaps(widget.donation),
            tooltip: 'Get Directions',
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _callDonor(widget.donation),
            tooltip: 'Call Donor',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Gallery
            if (AppConstants.imagesEnabled) _buildPhotoGallery(),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance Badge
                  if (distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km away',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Food Details Section
                  _buildSection(
                    'Food Details',
                    _buildFoodDetails(),
                  ),
                  const SizedBox(height: 24),

                  // Pickup Location Section
                  _buildSection(
                    'Pickup Location',
                    _buildLocationDetails(),
                  ),
                  const SizedBox(height: 24),

                  // Donor Contact Section
                  _buildSection(
                    'Donor Contact',
                    _buildDonorContact(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.donation.status.value == 'pending'
          ? _buildAcceptButton(context, provider)
          : null,
    );
  }

  Widget _buildPhotoGallery() {
    if (widget.donation.foodDetails.photos.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.donation.foodDetails.photos.length,
            onPageChanged: (index) {
              setState(() => _currentPhotoIndex = index);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _viewFullImage(context, index),
                child: Image.network(
                  widget.donation.foodDetails.photos[index].url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              );
            },
          ),
          if (widget.donation.foodDetails.photos.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPhotoIndex + 1}/${widget.donation.foodDetails.photos.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
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
    );
  }

  Widget _buildFoodDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              Icons.restaurant,
              'Food Type',
              widget.donation.foodDetails.foodType.value,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.description,
              'Description',
              widget.donation.foodDetails.description,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.people,
              'Can Feed',
              '${widget.donation.foodDetails.estimatedPeopleFed} people',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.scale,
              'Quantity',
              '${widget.donation.foodDetails.quantity.value.toStringAsFixed(0)} ${widget.donation.foodDetails.quantity.unit.value}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.schedule,
              'Best Before',
              DateFormat('MMM dd, yyyy hh:mm a').format(widget.donation.foodDetails.bestBefore),
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.donation.foodDetails.isVegetarian)
                  _buildBadge('Vegetarian', Colors.green, Icons.eco),
                if (widget.donation.foodDetails.isPackaged)
                  _buildBadge('Packaged', Colors.blue, Icons.inventory_2),
              ],
            ),
            if (widget.donation.foodDetails.allergens.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Allergens:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.donation.foodDetails.allergens
                    .map((a) => _buildBadge(a, Colors.orange, Icons.warning))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              Icons.location_on,
              'Address',
              widget.donation.pickupLocation.fullAddress,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.location_city,
              'City',
              '${widget.donation.pickupLocation.city}, ${widget.donation.pickupLocation.state}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.pin_drop,
              'Pincode',
              widget.donation.pickupLocation.pincode,
            ),
            if (widget.donation.pickupLocation.landmark?.isNotEmpty ?? false) ...[
              const Divider(height: 24),
              _buildDetailRow(
                Icons.place,
                'Landmark',
                widget.donation.pickupLocation.landmark!,
              ),
            ],
            if (widget.donation.pickupLocation.instructions?.isNotEmpty ?? false) ...[
              const Divider(height: 24),
              _buildDetailRow(
                Icons.info_outline,
                'Pickup Instructions',
                widget.donation.pickupLocation.instructions!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDonorContact() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              Icons.person,
              'Donor Name',
              widget.donation.donorInfo.name,
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    Icons.phone,
                    'Phone',
                    widget.donation.donorInfo.phone,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _callDonor(widget.donation),
                ),
              ],
            ),
            if (widget.donation.donorInfo.alternatePhone != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                Icons.phone_forwarded,
                'Alternate Phone',
                widget.donation.donorInfo.alternatePhone!,
              ),
            ],
            if (widget.donation.donorInfo.organizationName != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                Icons.business,
                'Organization',
                widget.donation.donorInfo.organizationName!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
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
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context, NGOProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () => _showAcceptDialog(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Accept This Donation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAcceptDialog(BuildContext context, NGOProvider provider) async {
    DateTime selectedTime = DateTime.now().add(const Duration(hours: 1));
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Accept Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('When can you collect this donation?'),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedTime),
                    );
                    
                    if (time != null) {
                      setState(() {
                        selectedTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Estimated Pickup Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy hh:mm a').format(selectedTime),
                  ),
                ),
              ),
            ],
          ),
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
      ),
    );

    if (result == true && context.mounted) {
      final success = await provider.acceptDonation(
        donationId: widget.donation.donationId,
        estimatedPickupTime: selectedTime.toIso8601String(),
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation accepted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to accept donation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewFullImage(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: widget.donation.foodDetails.photos.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.donation.foodDetails.photos[index].url,
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

  void _openMaps(DonationModel donation) async {
    final lat = donation.pickupLocation.latitude;
    final lng = donation.pickupLocation.longitude;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _callDonor(DonationModel donation) async {
    final phone = donation.donorInfo.phone;
    final url = Uri.parse('tel:$phone');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
