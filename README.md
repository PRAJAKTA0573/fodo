# FODO - Food Donation Bridge 🍽️❤️

**Connecting food donors with NGOs to reduce food waste and fight hunger in India**

[![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)

## 🌟 Project Vision

FODO is a mobile application designed to bridge the gap between food surplus and food scarcity in India by connecting food donors (individuals, restaurants, caterers, event organizers) with NGOs that distribute food to people in need.

## 📊 The Problem We're Solving

- **40% of food produced in India is wasted** (worth ₹92,000 crores annually)
- Weddings and events generate 40-50 kg of food waste on average
- **190 million people** go to bed hungry every night in India
- **14% of India's population** is undernourished
- No centralized platform to connect donors with NGOs efficiently

## 💡 Our Solution

FODO creates a digital bridge that:
- Allows donors to quickly post surplus food with photos and details
- Enables NGOs to discover and accept nearby food donations
- Provides real-time tracking and updates throughout the donation process
- Builds trust through transparency and confirmation systems
- Creates measurable social impact

## ✨ Key Features

### For Donors
- 📸 Quick donation request creation (under 2 minutes)
- 📍 Location-based NGO matching
- 🔔 Real-time status notifications
- 📊 Impact dashboard (people fed, donations made)
- ⭐ Rating and feedback system

### For NGOs
- 🗺️ Map view of nearby donations
- 🔍 Smart filtering (distance, food type, quantity)
- ✅ One-tap acceptance
- 📱 Direct communication with donors
- 📈 Analytics and collection history

### System Features
- 🔐 Secure authentication with NGO verification
- 🔄 Real-time push notifications
- 🌐 Google Maps integration
- 📷 Cloud storage for images
- 🏆 Gamification and impact tracking

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.32.8
- **Language:** Dart 3.8.1
- **State Management:** Provider/Riverpod
- **Navigation:** Go Router

### Backend
- **Database:** Firebase Firestore
- **Authentication:** Firebase Auth
- **Storage:** Firebase Storage
- **Notifications:** Firebase Cloud Messaging
- **Analytics:** Firebase Analytics
- **Crash Reporting:** Firebase Crashlytics

### Services
- **Maps:** Google Maps API
- **Location:** Geolocator
- **Image Processing:** Image Picker, Cropper, Compressor

## 📁 Project Structure

```
fodo/
├── lib/
│   ├── core/                 # Core utilities, constants, theme
│   ├── features/            # Feature modules (auth, donor, ngo)
│   │   ├── auth/
│   │   ├── donor/
│   │   ├── ngo/
│   │   └── shared/
│   └── services/            # Global services
├── assets/                  # Images, icons, fonts
├── docs/                    # Comprehensive documentation
│   ├── PROJECT_OVERVIEW.md
│   ├── DATABASE_SCHEMA.md
│   ├── API_DOCUMENTATION.md
│   └── ARCHITECTURE.md
└── test/                    # Unit, widget, integration tests
```

## 📚 Documentation

Detailed documentation is available in the `docs/` folder:

- **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Complete project vision, problem statement, solution, and 5-step implementation plan
- **[DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md)** - Firestore database design with all collections and security rules
- **[API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md)** - All API endpoints with request/response formats
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Technical architecture, design patterns, and best practices

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.32.8 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Xcode (for iOS development)
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/fodo.git
   cd fodo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a new Firebase project
   - Add Android and iOS apps
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Development Workflow

### Architecture

We follow **Clean Architecture** with a **feature-first** structure:

- **Presentation Layer:** UI, widgets, state management
- **Domain Layer:** Business logic, use cases, entities
- **Data Layer:** Models, repositories, data sources

### Code Quality

```bash
# Run linter
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Run integration tests
flutter test integration_test
```

## 📊 Project Status

### ✅ Step 1: Project Setup & Architecture Design (COMPLETED)

- [x] Technology stack selection
- [x] Project structure setup
- [x] Database schema design
- [x] API contracts definition
- [x] Documentation
- [x] Git repository initialization

### 🔄 Next Steps

- **Step 2:** Authentication & User Management
- **Step 3:** Core Features - Donor Side
- **Step 4:** Core Features - NGO Side  
- **Step 5:** Notifications, Testing & Deployment

## 🎯 Success Metrics

### Short-term (3 months)
- 500+ registered donors
- 50+ verified NGOs
- 1,000+ donations completed
- 10,000+ people fed

### Medium-term (6 months)
- 2,000+ registered donors
- 150+ verified NGOs
- 5,000+ donations completed
- 50,000+ people fed
- Present in 5+ cities

### Long-term (1 year)
- 10,000+ registered donors
- 500+ verified NGOs
- 25,000+ donations completed
- 250,000+ people fed
- Present in 20+ cities

## 🌍 Social Impact

### Environmental Impact
- Reduce food waste going to landfills
- Lower methane emissions
- Promote sustainable practices

### Social Impact
- Fight hunger and malnutrition
- Support underprivileged communities
- Build compassionate society
- Create volunteering opportunities

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Guidelines

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Write tests for new features
- Update documentation
- Keep commits atomic and meaningful

## 📄 License

[Choose appropriate license - MIT, Apache, etc.]

## 👥 Team

- **Project Lead:** [Your Name]
- **Flutter Developers:** [Team Members]
- **Backend Developer:** [Team Member]
- **UI/UX Designer:** [Team Member]

## 📞 Contact & Support

- **Email:** support@fodo.app
- **Phone:** +91-1234567890
- **Website:** https://www.fodo.app
- **Twitter:** [@fodoapp](https://twitter.com/fodoapp)
- **Instagram:** [@fodoapp](https://instagram.com/fodoapp)

## 🙏 Acknowledgments

- All NGOs and donors who inspire this project
- Flutter and Firebase communities
- Open source contributors

---

**Let's make every meal count! 🍽️❤️**

*Built with ❤️ to reduce food waste and fight hunger in India*

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
