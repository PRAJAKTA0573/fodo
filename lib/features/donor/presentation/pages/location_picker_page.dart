import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../services/location_service.dart';
import '../../data/models/donation_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Location Picker Page - Select pickup location on map
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final LocationService _locationService = LocationService();
  
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _address;
  Map<String, String>? _addressComponents;
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;
  
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  // Default location (can be changed to app's default city)
  static const LatLng _defaultLocation = LatLng(19.0760, 72.8777); // Mumbai

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _landmarkController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);

      final result = await _locationService.getCurrentLocation();

      if (!mounted) return;

      result.fold(
        (error) {
          // Use default location if current location fails
          setState(() {
            _selectedLocation = _defaultLocation;
            _isLoadingLocation = false;
          });
          _getAddressFromLocation(_defaultLocation);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not get current location: $error'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        (position) {
          final location = LatLng(position.latitude, position.longitude);
          setState(() {
            _selectedLocation = location;
            _isLoadingLocation = false;
          });
          _getAddressFromLocation(location);
          _animateToLocation(location);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedLocation = _defaultLocation;
        _isLoadingLocation = false;
      });
      _getAddressFromLocation(_defaultLocation);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getAddressFromLocation(LatLng location) async {
    setState(() => _isLoadingAddress = true);

    final result = await _locationService.getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );

    result.fold(
      (error) {
        setState(() {
          _isLoadingAddress = false;
          _address = 'Unable to fetch address';
        });
      },
      (addressMap) {
        setState(() {
          _isLoadingAddress = false;
          _address = addressMap['fullAddress'];
          _addressComponents = addressMap;
        });
      },
    );
  }

  void _animateToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      _animateToLocation(_selectedLocation!);
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromLocation(location);
  }

  void _confirmLocation() {
    if (_selectedLocation == null || _addressComponents == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pickupLocation = PickupLocation(
      fullAddress: _addressComponents!['fullAddress'] ?? '',
      city: _addressComponents!['city'] ?? '',
      state: _addressComponents!['state'] ?? '',
      pincode: _addressComponents!['pincode'] ?? '',
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
      instructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
    );

    Navigator.pop(context, pickupLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pickup Location'),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirmLocation,
              child: const Text('Confirm'),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? _defaultLocation,
              zoom: AppConstants.defaultZoom,
            ),
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation!,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() {
                          _selectedLocation = newPosition;
                        });
                        _getAddressFromLocation(newPosition);
                      },
                    ),
                  }
                : {},
          ),

          // Current Location Button
          Positioned(
            right: 16,
            bottom: 280,
            child: FloatingActionButton(
              heroTag: 'current_location',
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // Address Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Address Section
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_isLoadingAddress)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                Text(
                                  _address ?? 'Tap on map to select location',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_selectedLocation != null) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Landmark
                      TextField(
                        controller: _landmarkController,
                        decoration: const InputDecoration(
                          labelText: 'Landmark (Optional)',
                          hintText: 'e.g., Near City Mall',
                          prefixIcon: Icon(Icons.place_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Special Instructions
                      TextField(
                        controller: _instructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Pickup Instructions (Optional)',
                          hintText: 'Any specific directions for pickup',
                          prefixIcon: Icon(Icons.info_outline),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _confirmLocation,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Confirm Location'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Getting your location...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
