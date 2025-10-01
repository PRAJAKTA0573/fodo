import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'services/realtime_database_service.dart';
import 'services/donation_service.dart';
import 'services/image_upload_service.dart';
import 'services/location_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/donor/data/repositories/donation_repository_impl.dart';
import 'features/donor/presentation/providers/donation_provider.dart';
import 'features/donor/presentation/pages/donor_dashboard_page.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        
        // Repositories
        ProxyProvider2<FirebaseAuthService, RealtimeDatabaseService, AuthRepositoryImpl>(
          update: (_, authService, dbService, __) =>
              AuthRepositoryImpl(authService, dbService),
        ),
        ProxyProvider2<DonationService, ImageUploadService, DonationRepositoryImpl>(
          update: (_, donationService, imageService, __) =>
              DonationRepositoryImpl(donationService, imageService),
        ),
        
        // Providers
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthRepositoryImpl>(),
          )..checkAuthStatus(),
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
      ],
      child: MaterialApp(
        title: 'FODO - Food Donation Bridge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
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
                // TODO: Navigate to NGO dashboard
                return const HomePage();
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
