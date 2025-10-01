import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/donation_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'image_picker_page.dart';
import 'location_picker_page.dart';

/// Create Donation Page - Multi-step form for creating donations
class CreateDonationPage extends StatefulWidget {
  const CreateDonationPage({super.key});

  @override
  State<CreateDonationPage> createState() => _CreateDonationPageState();
}

class _CreateDonationPageState extends State<CreateDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form fields
  FoodType _selectedFoodType = FoodType.cookedFood;
  final _descriptionController = TextEditingController();
  double _quantityValue = 1;
  QuantityUnit _quantityUnit = QuantityUnit.people;
  int _estimatedPeopleFed = 1;
  bool _isVegetarian = true;
  bool _isPackaged = false;
  DateTime _bestBefore = DateTime.now().add(const Duration(hours: 4));
  List<String> _selectedAllergens = [];
  final _specialInstructionsController = TextEditingController();

  // Photos and Location
  List<File> _selectedPhotos = [];
  PickupLocation? _selectedLocation;

  final List<String> _allergenOptions = [
    'Nuts',
    'Dairy',
    'Eggs',
    'Gluten',
    'Soy',
    'Shellfish',
    'Fish',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _specialInstructionsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitDonation();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Food Details
        if (!_formKey.currentState!.validate()) return false;
        if (_descriptionController.text.trim().isEmpty) {
          _showError('Please provide a food description');
          return false;
        }
        return true;
      case 1: // Photos
        if (_selectedPhotos.isEmpty) {
          _showError('Please add at least one photo');
          return false;
        }
        return true;
      case 2: // Location
        if (_selectedLocation == null) {
          _showError('Please select pickup location');
          return false;
        }
        return true;
      case 3: // Review
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submitDonation() async {
    if (!_validateCurrentStep()) return;

    final authProvider = context.read<AuthProvider>();
    final donationProvider = context.read<DonationProvider>();

    if (authProvider.currentUser == null) {
      _showError('User not authenticated');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final user = authProvider.currentUser!;

    // Create donation model
    final donation = DonationModel(
      donationId: '', // Will be generated
      donorId: user.userId,
      donorInfo: DonorInfo(
        name: user.profileData.fullName.isNotEmpty ? user.profileData.fullName : 'Donor',
        phone: user.phoneNumber.isNotEmpty ? user.phoneNumber : '',
        organizationName: null,
      ),
      foodDetails: FoodDetails(
        foodType: _selectedFoodType,
        description: _descriptionController.text.trim(),
        quantity: Quantity(
          value: _quantityValue,
          unit: _quantityUnit,
        ),
        estimatedPeopleFed: _estimatedPeopleFed,
        bestBefore: _bestBefore,
        isVegetarian: _isVegetarian,
        isPackaged: _isPackaged,
        allergens: _selectedAllergens,
        photos: [], // Will be uploaded
      ),
      pickupLocation: _selectedLocation!,
      status: DonationStatus.created,
      timeline: Timeline(
        createdAt: DateTime.now(),
      ),
      specialInstructions: _specialInstructionsController.text.trim().isEmpty
          ? null
          : _specialInstructionsController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt: DateTime.now().add(
        Duration(hours: AppConstants.donationExpiryHours),
      ),
    );

    // Create donation with photos
    final success = await donationProvider.createDonationWithPhotos(
      donation,
      _selectedPhotos,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (success) {
      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      // Show error
      if (mounted) {
        _showError(donationProvider.errorMessage ?? 'Failed to create donation');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Donation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(),
        ),
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),
          
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFoodDetailsStep(),
                _buildPhotosStep(),
                _buildLocationStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFoodDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Food Type
            Text(
              'Food Type *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FoodType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: _selectedFoodType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFoodType = type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'e.g., Rice, Curry, Bread',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Quantity
            Text(
              'Quantity *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: _quantityValue.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _quantityValue = double.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<QuantityUnit>(
                    value: _quantityUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: QuantityUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _quantityUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Estimated People Fed
            TextFormField(
              initialValue: _estimatedPeopleFed.toString(),
              decoration: const InputDecoration(
                labelText: 'Estimated People Fed *',
                hintText: 'Approximate number of people',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _estimatedPeopleFed = int.tryParse(value) ?? 1;
                });
              },
            ),
            const SizedBox(height: 24),

            // Vegetarian Switch
            SwitchListTile(
              title: const Text('Vegetarian'),
              value: _isVegetarian,
              onChanged: (value) => setState(() => _isVegetarian = value),
              contentPadding: EdgeInsets.zero,
            ),

            // Packaged Switch
            SwitchListTile(
              title: const Text('Packaged Food'),
              value: _isPackaged,
              onChanged: (value) => setState(() => _isPackaged = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Best Before
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Best Before'),
              subtitle: Text(
                '${_bestBefore.day}/${_bestBefore.month}/${_bestBefore.year} at ${_bestBefore.hour}:${_bestBefore.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectBestBefore,
            ),
            const SizedBox(height: 16),

            // Allergens
            Text(
              'Allergens (if any)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergenOptions.map((allergen) {
                return FilterChip(
                  label: Text(allergen),
                  selected: _selectedAllergens.contains(allergen),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergens.add(allergen);
                      } else {
                        _selectedAllergens.remove(allergen);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Food Photos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add at least one photo of the food (max ${AppConstants.maxDonationPhotos})',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Selected Photos Grid
          if (_selectedPhotos.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedPhotos[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPhotos.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          const SizedBox(height: 16),

          // Add Photos Button
          if (_selectedPhotos.length < AppConstants.maxDonationPhotos)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickPhotos,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(
                  _selectedPhotos.isEmpty ? 'Add Photos' : 'Add More Photos',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Location',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where should the NGO pick up the food?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          if (_selectedLocation != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedLocation!.fullAddress,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedLocation!.landmark != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Landmark: ${_selectedLocation!.landmark}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: Icon(_selectedLocation == null
                  ? Icons.add_location
                  : Icons.edit_location),
              label: Text(
                _selectedLocation == null
                    ? 'Select Location'
                    : 'Change Location',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          _buildReviewSection('Food Details', [
            _buildReviewItem('Type', _selectedFoodType.displayName),
            _buildReviewItem('Description', _descriptionController.text),
            _buildReviewItem(
              'Quantity',
              '${_quantityValue.toStringAsFixed(0)} ${_quantityUnit.displayName}',
            ),
            _buildReviewItem('People Fed', _estimatedPeopleFed.toString()),
            _buildReviewItem('Vegetarian', _isVegetarian ? 'Yes' : 'No'),
            _buildReviewItem('Packaged', _isPackaged ? 'Yes' : 'No'),
          ]),

          const SizedBox(height: 16),

          _buildReviewSection('Photos', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedPhotos.map((photo) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    photo,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
          ]),

          const SizedBox(height: 16),

          if (_selectedLocation != null)
            _buildReviewSection('Pickup Location', [
              _buildReviewItem('Address', _selectedLocation!.fullAddress),
              if (_selectedLocation!.landmark != null)
                _buildReviewItem('Landmark', _selectedLocation!.landmark!),
            ]),

          const SizedBox(height: 24),

          TextFormField(
            controller: _specialInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Special Instructions (Optional)',
              hintText: 'Any special notes for the NGO',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: Text(
                _currentStep < _totalSteps - 1 ? 'Next' : 'Submit',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBestBefore() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _bestBefore,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_bestBefore),
      );

      if (time != null) {
        setState(() {
          _bestBefore = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickPhotos() async {
    final result = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePickerPage(
          maxImages: AppConstants.maxDonationPhotos - _selectedPhotos.length,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(result);
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<PickupLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Donation?'),
        content: const Text(
          'Are you sure you want to cancel? All entered information will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close create page
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
