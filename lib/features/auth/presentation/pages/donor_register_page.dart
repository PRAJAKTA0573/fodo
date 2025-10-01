import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

/// Donor registration page with comprehensive form
class DonorRegisterPage extends StatefulWidget {
  const DonorRegisterPage({super.key});

  @override
  State<DonorRegisterPage> createState() => _DonorRegisterPageState();
}

class _DonorRegisterPageState extends State<DonorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers (no email/password needed for Google Sign-In)
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _organizationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }


  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    if (value.length != 6) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    // Complete Google Sign-In registration
    // Note: Coordinates would normally come from location picker/geocoding
    // For now, using placeholder values (0,0)
    await authProvider.completeGoogleSignInDonor(
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      latitude: 0.0, // TODO: Implement location picker with geocoding
      longitude: 0.0, // TODO: Implement location picker with geocoding
      organizationName: _organizationController.text.trim().isEmpty 
          ? null 
          : _organizationController.text.trim(),
    );

    if (authProvider.errorMessage == null && mounted) {
      // Registration successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate back to home (will redirect to dashboard)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Registration'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Icon(
                      Icons.volunteer_activism,
                      size: 60,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Complete Your Donor Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tell us a bit more about yourself to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Contact Information Section
                    const AuthSectionHeader(
                      title: 'Contact Information',
                      subtitle: 'How can NGOs reach you?',
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '10-digit mobile number',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      maxLength: 10,
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _organizationController,
                      label: 'Organization Name (Optional)',
                      hint: 'Restaurant, Catering, Event, etc.',
                      prefixIcon: Icons.business,
                    ),
                    const SizedBox(height: 32),

                    // Location Section
                    const AuthSectionHeader(
                      title: 'Location Details',
                      subtitle: 'Where should NGOs pick up donations?',
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _addressController,
                      label: 'Full Address',
                      hint: 'Street address, landmark',
                      prefixIcon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AuthTextField(
                            controller: _cityController,
                            label: 'City',
                            prefixIcon: Icons.location_city,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AuthTextField(
                            controller: _stateController,
                            label: 'State',
                            prefixIcon: Icons.map,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      hint: '6-digit pincode',
                      prefixIcon: Icons.pin_drop,
                      keyboardType: TextInputType.number,
                      validator: _validatePincode,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 24),

                    // Error Message
                    if (authProvider.errorMessage != null)
                      AuthErrorMessage(message: authProvider.errorMessage!),

                    // Terms & Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreedToTerms = !_agreedToTerms;
                              });
                            },
                            child: const Text(
                              'I agree to the Terms & Conditions and Privacy Policy',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register Button
                    AuthButton(
                      text: 'Register as Donor',
                      icon: Icons.app_registration,
                      onPressed: _handleRegistration,
                      isLoading: authProvider.isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Already have account
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Already have an account? Login'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            if (authProvider.isLoading)
              const AuthLoadingOverlay(
                message: 'Creating your account...',
              ),
          ],
        ),
      ),
    );
  }
}
