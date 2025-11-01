# HealthTracker iOS App

A comprehensive healthcare tracking iOS app built with Swift and SwiftUI for managing diabetes, cholesterol, blood pressure, exercise, food logging, and AI-powered health coaching.

## 🎯 Features

### Core Health Tracking
- **Blood Sugar Monitoring** - Track glucose levels with measurement type classification
- **Blood Pressure Tracking** - Monitor systolic/diastolic readings with heart rate
- **Cholesterol Management** - Record total, LDL, HDL, and triglycerides
- **Sleep Tracking** - Log sleep duration and quality
- **Step Counter** - Daily step goal tracking with progress visualization
- **Food Logging** - Manual entry with nutrition data (calories, macros)
- **Photo Food Recognition** - Placeholder for Vision-based food identification

### Premium Features
- **AI Health Coach** - Personalized chat-based health advice and motivation
- **Advanced Charts** - Weekly, monthly, quarterly, and yearly trend analysis
- **Smart Insights** - Pattern recognition and habit suggestions
- **PDF Export** - Generate comprehensive health reports
- **Photo Food Analysis** - Vision-based meal recognition (placeholder)

### User Experience
- **Onboarding Flow** - Multi-step profile setup (age, weight, conditions, goals)
- **Dashboard** - At-a-glance health metrics with status indicators
- **Tab Navigation** - Easy access to Home, Food, Charts, AI Coach, and Settings
- **Notifications** - Gentle reminders for glucose checks, water, and activity
- **Subscription Paywall** - $10/month with 7-day free trial

## 📁 Project Structure

```
HealthTracker/
├── App/
│   ├── HealthTrackerApp.swift          # App entry point with services
│   └── ContentView.swift                # Main tab bar navigation
│
├── Models/
│   ├── User.swift                       # User profile with onboarding data
│   ├── BloodSugar.swift                 # Blood glucose tracking
│   ├── BloodPressure.swift              # BP with heart rate
│   ├── Cholesterol.swift                # Lipid panel tracking
│   ├── FoodEntry.swift                  # Meal logging with nutrition
│   ├── Exercise.swift                   # Activity tracking
│   └── HealthMetric.swift               # Sleep, steps, water entries
│
├── ViewModels/
│   ├── OnboardingViewModel.swift        # Onboarding flow logic
│   ├── DashboardViewModel.swift         # Home screen data
│   ├── FoodLogViewModel.swift           # Food logging with AI recognition
│   ├── AIChatViewModel.swift            # Chat coach conversation
│   ├── ChartsViewModel.swift            # Data visualization logic
│   └── SettingsViewModel.swift          # Profile and preferences
│
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift         # 4-step onboarding
│   ├── Dashboard/
│   │   ├── DashboardView.swift          # Home with metric cards
│   │   └── Components/
│   │       ├── MetricCard.swift         # Reusable metric card
│   │       ├── BloodSugarCard.swift     # Glucose display
│   │       ├── BloodPressureCard.swift  # BP display
│   │       ├── CholesterolCard.swift    # Lipid display
│   │       ├── StepsCard.swift          # Steps with progress
│   │       └── SleepCard.swift          # Sleep duration
│   ├── FoodLog/
│   │   └── FoodLogView.swift            # Food entry list and add
│   ├── AIChat/
│   │   └── AIChatView.swift             # Conversational AI coach
│   ├── Charts/
│   │   └── ChartsView.swift             # Health trends and insights
│   ├── Settings/
│   │   └── SettingsView.swift           # Profile, export, preferences
│   └── Paywall/
│       └── PaywallView.swift            # Subscription screen
│
├── Services/
│   ├── PersistenceService.swift         # AppStorage/UserDefaults persistence
│   ├── HealthKitService.swift           # HealthKit integration
│   ├── AIService.swift                  # AI chat and food recognition
│   └── NotificationService.swift        # Local notifications
│
└── Utilities/
    ├── Constants.swift                  # App-wide constants
    ├── Extensions/
    │   ├── Color+Extensions.swift       # Custom colors and gradients
    │   ├── Date+Extensions.swift        # Date formatting helpers
    │   └── View+Extensions.swift        # SwiftUI view modifiers
    └── Helpers/
        └── PDFExporter.swift            # Health report PDF generator
```

## 🏗️ Architecture

### MVVM Pattern
- **Models**: Pure data structures with computed properties
- **Views**: SwiftUI declarative UI components
- **ViewModels**: Business logic and state management with `@MainActor`

### Data Persistence
- **MVP**: AppStorage and UserDefaults for simple storage
- **Future**: Can be upgraded to CoreData for advanced features
- **HealthKit**: Bidirectional sync with Apple Health (optional)

### Services Layer
- **Singleton Pattern**: Shared instances for app-wide services
- **Async/Await**: Modern concurrency for all network and data operations
- **ObservableObject**: Reactive state management with Combine

## 🎨 Design Guidelines

### Apple HIG Compliance
- Native SwiftUI components
- Dynamic Type support
- Dark Mode compatible
- SF Symbols for icons
- Standard navigation patterns

### Color System
- Blood Sugar: Red
- Blood Pressure: Pink
- Cholesterol: Purple
- Steps: Green
- Sleep: Indigo
- Food: Orange

### Status Colors
- Low: Blue
- Normal: Green
- Elevated: Yellow
- High: Orange
- Very High: Red

## 🚀 Getting Started

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

### Setup
1. Open the project in Xcode
2. Select your development team
3. Configure Bundle Identifier
4. Enable HealthKit capability (if needed)
5. Add UserNotifications capability
6. Build and run

### Configuration
Update `Constants.swift` with your API keys:
- OpenAI API key (for AI chat)
- Nutrition API key (for food database)

Update `Info.plist`:
- Privacy - Health Share Usage Description
- Privacy - Health Update Usage Description
- Privacy - Notifications Usage Description

## 📱 Features Implementation Status

### ✅ Completed (Scaffold)
- [x] Project structure
- [x] MVVM architecture
- [x] All models with validation
- [x] All ViewModels with business logic
- [x] All Views with navigation
- [x] Dashboard with metric cards
- [x] Onboarding flow
- [x] Food logging
- [x] AI chat interface
- [x] Charts visualization
- [x] Settings and profile
- [x] Paywall with trial
- [x] Services layer
- [x] Extensions and utilities

### 🔄 To Implement
- [ ] Actual HealthKit data reading/writing
- [ ] Real AI integration (OpenAI API)
- [ ] Vision-based food recognition
- [ ] Swift Charts for data visualization
- [ ] StoreKit 2 for subscriptions
- [ ] CoreData migration (optional)
- [ ] Widget extension
- [ ] Apple Watch companion app
- [ ] Siri shortcuts
- [ ] Export to CSV/JSON
- [ ] Cloud sync with iCloud

## 🔐 Privacy & Security

### Data Storage
- All health data stored locally on device
- UserDefaults for MVP (can upgrade to encrypted CoreData)
- Optional HealthKit sync (user controlled)
- No data sent to servers without explicit consent

### HIPAA Considerations
- This is a personal health tracking app
- Not a medical device
- Includes disclaimers throughout
- Recommends consulting healthcare providers

## 📄 License

Copyright © 2024 Delta Founder. All rights reserved.

## 🤝 Contributing

This is a private project. Contact the repository owner for collaboration.

## 📞 Support

For issues or questions, contact the repository owner.

---

**⚠️ Medical Disclaimer**: This app is for informational and tracking purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult your physician or other qualified health provider with any questions regarding a medical condition.