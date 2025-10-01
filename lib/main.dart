import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'services/realtime_database_service.dart';
import 'services/donation_service.dart';
import 'services/image_upload_service.dart';
import 'services/location_service.dart';
import 'services/ngo_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/donor/data/repositories/donation_repository_impl.dart';
import 'features/donor/presentation/providers/donation_provider.dart';
import 'features/donor/presentation/pages/donor_dashboard_page.dart';
import 'features/ngo/data/repositories/ngo_repository_impl.dart';
import 'features/ngo/presentation/providers/ngo_provider.dart';
import 'features/ngo/presentation/pages/ngo_dashboard_page.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, continue
    print('Firebase already initialized: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => FirebaseAuthService()),
        Provider(create: (_) => RealtimeDatabaseService()),
        Provider(create: (_) => DonationService()),
        Provider(create: (_) => ImageUploadService()),
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => NGOService()),
        
        // Repositories
        ProxyProvider2<FirebaseAuthService, RealtimeDatabaseService, AuthRepositoryImpl>(
          update: (_, authService, dbService, __) =>
              AuthRepositoryImpl(authService, dbService),
        ),
        ProxyProvider2<DonationService, ImageUploadService, DonationRepositoryImpl>(
          update: (_, donationService, imageService, __) =>
              DonationRepositoryImpl(donationService, imageService),
        ),
        ProxyProvider2<NGOService, RealtimeDatabaseService, NGORepositoryImpl>(
          update: (_, ngoService, dbService, __) =>
              NGORepositoryImpl(ngoService, dbService),
        ),
        
        // Providers
        ChangeNotifierProvider(
          create: (context) {
            final authProvider = AuthProvider(
              context.read<AuthRepositoryImpl>(),
            );
            // Check auth status after frame is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.checkAuthStatus();
            });
            return authProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DonationProvider>(
          create: (context) => DonationProvider(
            context.read<DonationRepositoryImpl>(),
          ),
          update: (context, authProvider, donationProvider) {
            // Reload donations when user changes
            if (authProvider.currentUser != null && donationProvider != null) {
              donationProvider.loadDonations(authProvider.currentUser!.userId);
            }
            return donationProvider ?? DonationProvider(
              context.read<DonationRepositoryImpl>(),
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NGOProvider>(
          create: (context) => NGOProvider(
            context.read<NGORepositoryImpl>(),
            '', // Will be set when user is authenticated
          ),
          update: (context, authProvider, ngoProvider) {
            // Create new provider when NGO user logs in
            if (authProvider.currentUser != null && 
                authProvider.currentUser!.userType == UserType.ngo) {
              return NGOProvider(
                context.read<NGORepositoryImpl>(),
                authProvider.currentUser!.userId,
              );
            }
            return ngoProvider ?? NGOProvider(
              context.read<NGORepositoryImpl>(),
              '',
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'FODO - Food Donation Bridge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Can be changed to ThemeMode.system for system preference
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Show loading while checking auth status
            if (authProvider.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Navigate based on auth status and user type
            if (authProvider.isAuthenticated) {
              final userType = authProvider.currentUser?.userType;
              
              if (userType == UserType.donor) {
                return const DonorDashboardPage();
              } else if (userType == UserType.ngo) {
                return const NGODashboardPage();
              } else {
                // Default to home page for admin or unknown type
                return const HomePage();
              }
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
