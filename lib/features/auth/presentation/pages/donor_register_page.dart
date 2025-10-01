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

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _organizationController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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

    // Note: Coordinates would normally come from location picker/geocoding
    // For now, using placeholder values (0,0)
    await authProvider.registerDonor(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
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
          content: Text('Registration successful! Please verify your email.'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate back to login
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
                      'Become a Food Donor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help reduce food waste and feed those in need',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Personal Information Section
                    const AuthSectionHeader(
                      title: 'Personal Information',
                      subtitle: 'Tell us about yourself',
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'your.email@example.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
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
                    const SizedBox(height: 32),

                    // Security Section
                    const AuthSectionHeader(
                      title: 'Security',
                      subtitle: 'Create a secure password',
                    ),
                    const SizedBox(height: 16),

                    AuthPasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'At least 6 characters',
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),

                    AuthPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter password',
                      validator: _validateConfirmPassword,
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
