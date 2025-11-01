# HealthTrack AI - iOS Healthcare App

A comprehensive iOS healthcare AI app built with SwiftUI that tracks food intake using photos, monitors health data via Apple HealthKit, provides AI-personalized plans, and gamifies health progress.

## 📱 Features

### Core Features
- **Photo Food Tracking**: Snap photos to automatically identify foods and calculate nutrition
- **Apple HealthKit Integration**: Sync glucose, steps, weight, blood pressure, and sleep
- **AI Personalized Plans**: Monthly auto-adjusting meal and nutrition plans
- **Predictive Analytics**: 7-day glucose forecasting using ML
- **Smart Alerts**: Glucose spike warnings, cholesterol patterns, inactivity nudges
- **Gamification**: Streaks, trophies, XP system, health points (HP)
- **Health Charts**: Trend visualization with 7/30/90-day views

### Premium Features ($9.99/month)
- Unlimited photo food tracking
- AI monthly plan adjustments
- Health trend predictions
- Full gamification system
- Smart health alerts
- Meal & grocery recommendations
- PDF health reports export

## 🛠 Tech Stack

### iOS
- **SwiftUI** (iOS 17+)
- **HealthKit** - Health data integration
- **Vision & CoreML** - Food recognition
- **StoreKit 2** - Subscriptions
- **Charts** - Data visualization
- **PhotosUI** - Photo picking
- **UserNotifications** - Push notifications

### Backend
- **Firebase Auth** - User authentication
- **Firestore** - NoSQL database
- **Firebase Storage** - Photo storage
- **Cloud Functions** - Serverless logic

### ML Models
- Food recognition (CoreML)
- Nutrition estimation
- LSTM for glucose prediction

## 📦 Project Structure

```
HealthTrackAI/
├── HealthTrackAI/
│   ├── HealthTrackAIApp.swift          # App entry point
│   ├── ContentView.swift               # Root navigation
│   │
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Meal.swift
│   │   ├── HealthLog.swift
│   │   ├── MonthlyPlan.swift
│   │   └── Trophy.swift
│   │
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   ├── MealViewModel.swift
│   │   ├── HealthViewModel.swift
│   │   ├── GamificationViewModel.swift
│   │   └── PlanViewModel.swift
│   │
│   ├── Views/
│   │   ├── Onboarding/
│   │   ├── Home/
│   │   ├── Meals/
│   │   ├── Health/
│   │   ├── Plan/
│   │   ├── Gamification/
│   │   ├── Profile/
│   │   └── Components/
│   │
│   ├── Services/
│   │   ├── FirebaseService.swift
│   │   ├── HealthKitManager.swift
│   │   ├── MLService.swift
│   │   ├── NotificationManager.swift
│   │   └── SubscriptionManager.swift
│   │
│   └── Utilities/
│       ├── Extensions.swift
│       └── Constants.swift
│
├── firestore.rules                     # Firestore security rules
├── storage.rules                       # Storage security rules
└── GoogleService-Info.plist            # Firebase config (not included)
```

## 🚀 Setup Instructions

### Prerequisites
- **Xcode 15+** with iOS 17 SDK
- **Apple Developer Account** ($99/year)
- **Firebase Account** (Free tier)
- **macOS** Sonoma or later

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/HealthTrackAI.git
cd HealthTrackAI
```

### Step 2: Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Click "Add Project"
   - Name it "HealthTrack AI"
   - Disable Google Analytics (optional)

2. **Add iOS App**
   - Click "Add app" → iOS
   - Bundle ID: `com.yourcompany.healthtrackai`
   - Download `GoogleService-Info.plist`
   - Place it in `HealthTrackAI/HealthTrackAI/` directory

3. **Enable Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

4. **Create Firestore Database**
   - Go to Firestore Database → Create database
   - Start in **production mode**
   - Choose location (us-central1 recommended)

5. **Deploy Security Rules**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools

   # Login
   firebase login

   # Initialize
   firebase init firestore

   # Deploy rules
   firebase deploy --only firestore:rules
   firebase deploy --only storage:rules
   ```

6. **Enable Storage**
   - Go to Storage → Get Started
   - Start in production mode

### Step 3: Xcode Configuration

1. **Open Project**
   ```bash
   open HealthTrackAI/HealthTrackAI.xcodeproj
   ```

2. **Set Bundle Identifier**
   - Select project in navigator
   - Go to "Signing & Capabilities"
   - Change Bundle Identifier to match your Firebase app
   - Select your development team

3. **Add HealthKit Capability**
   - Click "+ Capability"
   - Add "HealthKit"

4. **Add In-App Purchase Capability**
   - Click "+ Capability"
   - Add "In-App Purchase"

5. **Add Background Modes**
   - Click "+ Capability"
   - Add "Background Modes"
   - Check "Remote notifications"

### Step 4: App Store Connect Setup

1. **Create App**
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Click "My Apps" → "+"
   - Name: HealthTrack AI
   - Bundle ID: (select from dropdown)
   - SKU: healthtrackai

2. **Create In-App Purchases**
   - Go to your app → Features → In-App Purchases
   - Click "+"

   **Monthly Subscription:**
   - Type: Auto-Renewable Subscription
   - Reference Name: Premium Monthly
   - Product ID: `com.yourcompany.healthtrackai.premium.monthly`
   - Subscription Duration: 1 Month
   - Price: $9.99 (Tier 10)
   - Free Trial: 7 days

   **Annual Subscription (optional):**
   - Product ID: `com.yourcompany.healthtrackai.premium.annual`
   - Duration: 1 Year
   - Price: $79.99

3. **Update Constants.swift**
   ```swift
   static let monthlyProductID = "com.yourcompany.healthtrackai.premium.monthly"
   static let annualProductID = "com.yourcompany.healthtrackai.premium.annual"
   ```

### Step 5: Build and Run

1. **Select Target Device**
   - Choose a physical iPhone (iOS 17+) or Simulator

2. **Build**
   - Press `Cmd + B` to build
   - Fix any errors

3. **Run**
   - Press `Cmd + R` to run
   - Grant permissions when prompted

### Step 6: Test In-App Purchases (Sandbox)

1. **Create Sandbox Tester**
   - App Store Connect → Users and Access → Sandbox Testers
   - Click "+" to add tester
   - Use a new email (not your Apple ID)

2. **Test on Device**
   - Sign out of App Store on device
   - Run app
   - Try to purchase Premium
   - Sign in with sandbox account when prompted

## 🔥 Firebase Setup Details

### Firestore Collections Structure

```
users/
  {userId}/
    - email, profile, subscription, gamification
    meals/
      {mealId}/
        - timestamp, foods, totals, photo_url
    health_logs/
      {logId}/
        - timestamp, type, value, source
    monthly_plans/
      {planId}/
        - month, targets, adjustments, suggestions
    predictions/
      {predictionId}/
        - type, predictions, generated_at

food_database/
  {foodId}/
    - name, nutrition_per_100g, common_serving
```

### Initial Data Setup

Create a `food_database` collection with common foods:

```javascript
// Firebase Console → Firestore → Add collection
{
  "name": "Banana",
  "nutrition_per_100g": {
    "calories": 89,
    "carbs_g": 23,
    "protein_g": 1.1,
    "fat_g": 0.3,
    "fiber_g": 2.6
  },
  "common_serving": {
    "amount": 118,
    "unit": "g",
    "description": "1 medium banana"
  }
}
```

Add 50-100 common foods for MVP. Use [USDA FoodData Central API](https://fdc.nal.usda.gov/api-guide.html) to fetch nutrition data.

## 📱 App Store Submission

### Pre-Submission Checklist

- [ ] Bundle ID matches App Store Connect
- [ ] Version number set (1.0.0)
- [ ] Build configuration set to Release
- [ ] Remove all test/debug code
- [ ] Test on physical device
- [ ] All placeholder text removed
- [ ] Privacy Policy URL added
- [ ] Terms of Service URL added
- [ ] Medical disclaimer visible in app

### Screenshots Required

Take screenshots on these devices:
- iPhone 15 Pro Max (6.7"): 3-10 screenshots
- iPhone 11 Pro Max (6.5"): 3-10 screenshots

**Recommended screenshots:**
1. Home screen with HP bar and streaks
2. Photo food logging demo
3. Glucose trend chart
4. Monthly plan screen
5. Trophy cabinet

### App Store Description

See blueprint above for complete App Store description template.

### App Privacy Details

In App Store Connect → App Privacy:

**Data Collected:**
- ✅ Health & Fitness (linked to user, for app functionality)
- ✅ Photos (not linked to user, processed locally)
- ✅ Contact Info - Email (linked to user)
- ✅ Identifiers - User ID (linked to user)

### Submit for Review

1. **Archive App**
   - Xcode → Product → Archive
   - Organizer → Validate App
   - Fix any issues
   - Distribute App → App Store Connect → Upload

2. **Complete App Information**
   - Fill out all required fields
   - Add screenshots
   - Set pricing ($0 for base app)
   - Add demo account info for reviewers

3. **Submit**
   - Click "Submit for Review"
   - Wait 24-48 hours

## 🧪 Testing

### Unit Testing
```bash
# Run tests
Cmd + U
```

### Manual Testing Checklist

- [ ] Sign up new account
- [ ] Complete onboarding
- [ ] Grant HealthKit permissions
- [ ] Log meal with photo
- [ ] View health charts
- [ ] Generate monthly plan
- [ ] Earn XP and trophies
- [ ] Test streak tracking
- [ ] Purchase Premium (sandbox)
- [ ] Restore purchases
- [ ] Sign out/in

## 💰 Cost Breakdown

| Item | Cost | Notes |
|------|------|-------|
| Apple Developer Program | $99/year | Required |
| Firebase (Free tier) | $0 | Up to 50k reads/day |
| Domain (optional) | $12-25/year | For privacy policy |
| **TOTAL** | **~$100-125/year** | ✅ Under $200 budget |

## 📈 Marketing & Launch

### Pre-Launch (2 weeks before)
- [ ] Create landing page
- [ ] Set up social media accounts
- [ ] Prepare 5-10 TikTok videos
- [ ] Join diabetes/health Reddit communities
- [ ] Recruit 10 beta testers

### Launch Day
- [ ] Submit to Product Hunt
- [ ] Post in relevant subreddits
- [ ] Email beta testers for reviews
- [ ] Start TikTok content schedule (3x/week)

### Post-Launch
- [ ] Respond to all App Store reviews
- [ ] Monitor Firebase Analytics
- [ ] Weekly feature updates
- [ ] Run Facebook/Instagram ads ($50/week budget)

## 🐛 Troubleshooting

### Common Issues

**1. "GoogleService-Info.plist not found"**
- Solution: Download from Firebase Console and add to project

**2. "HealthKit authorization failed"**
- Solution: Check Info.plist has NSHealthShareUsageDescription

**3. "Subscription purchase fails"**
- Solution: Use sandbox tester account, sign out of App Store first

**4. "Firebase auth error"**
- Solution: Enable Email/Password in Firebase Console

**5. "Build fails - module not found"**
- Solution: Clean build folder (Cmd + Shift + K), rebuild

## 📚 Resources

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [StoreKit 2 Guide](https://developer.apple.com/documentation/storekit)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## 📧 Support

For questions or issues:
- Email: support@healthtrackai.com
- GitHub Issues: [Create Issue](https://github.com/yourusername/HealthTrackAI/issues)

---

**Built with ❤️ using SwiftUI, Firebase, and AI**

*Remember: This app is for informational purposes only and is not a substitute for professional medical advice.*
