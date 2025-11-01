# Quick Start Guide - HealthTrack AI

Get the app running in 15 minutes! ⚡

## Prerequisites Checklist

- [ ] Mac with macOS Sonoma+
- [ ] Xcode 15+ installed
- [ ] Apple Developer Account ($99/year)
- [ ] Firebase account (free)

## 5-Minute Firebase Setup

### 1. Create Firebase Project (2 min)

1. Go to https://console.firebase.google.com
2. Click **"Add project"**
3. Name: `HealthTrack-AI`
4. Disable Analytics → **Create project**

### 2. Add iOS App (2 min)

1. Click **iOS+** icon
2. Bundle ID: `com.yourname.healthtrackai` (use your name)
3. Click **Register app**
4. Download `GoogleService-Info.plist`
5. Click **Continue** (skip remaining steps)

### 3. Enable Services (1 min)

**Authentication:**
- Left menu → **Authentication** → Get Started
- Sign-in method tab → **Email/Password** → Enable → Save

**Firestore:**
- Left menu → **Firestore Database** → Create database
- Start in **production mode** → Select region → Enable

**Storage:**
- Left menu → **Storage** → Get Started
- Start in **production mode** → Done

## 10-Minute Xcode Setup

### 1. Add Firebase Config (1 min)

```bash
# In Terminal:
cd /path/to/HealthTrackAI
mv ~/Downloads/GoogleService-Info.plist HealthTrackAI/HealthTrackAI/
```

### 2. Install Firebase SDK (2 min)

**Option A: Swift Package Manager (Recommended)**

1. Open `HealthTrackAI.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Paste: `https://github.com/firebase/firebase-ios-sdk`
4. Version: Up to Next Major (10.0.0)
5. Add packages:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseAnalytics
6. Click **Add Package**

**Option B: CocoaPods**

```bash
# Create Podfile
cd HealthTrackAI
pod init

# Edit Podfile:
target 'HealthTrackAI' do
  use_frameworks!

  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Analytics'
end

# Install
pod install

# Open workspace (NOT .xcodeproj)
open HealthTrackAI.xcworkspace
```

### 3. Configure Signing (2 min)

1. Select **HealthTrackAI** project in navigator
2. Select **HealthTrackAI** target
3. **Signing & Capabilities** tab
4. Check ✓ **Automatically manage signing**
5. Team: Select your Apple Developer team
6. Change Bundle Identifier to: `com.yourname.healthtrackai`

### 4. Add Capabilities (1 min)

Click **+ Capability** button:
1. Add **HealthKit**
2. Add **In-App Purchase**
3. Add **Background Modes** → Check "Remote notifications"

### 5. Deploy Firebase Rules (2 min)

```bash
# Install Firebase CLI (if not installed)
curl -sL https://firebase.tools | bash

# Login
firebase login

# Initialize project
cd HealthTrackAI
firebase init

# Select:
# - Firestore
# - Storage
# Use existing project: HealthTrack-AI
# Accept default firestore.rules and storage.rules paths

# Deploy
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### 6. Build & Run (2 min)

1. Select target: **iPhone 15 Pro** (Simulator)
2. Press **Cmd + R** to build and run
3. Wait for app to launch

**First Launch:**
- Tap **Get Started**
- Complete onboarding (select any options)
- Create account with email/password
- Grant permissions (or skip for now)
- You're in! 🎉

## Testing the App

### Test Photo Food Logging

1. Tap **"Add Meal Photo"** on home screen
2. Select any food photo (or take one)
3. Wait 2 seconds for AI analysis
4. See detected foods with nutrition
5. Tap **"Confirm & Log Meal"**
6. See meal appear on home screen

### Test Health Sync (Physical Device Only)

1. Open **Apple Health** app
2. Browse → Health Categories → **Blood Glucose** → Add Data
3. Enter: 115 mg/dL → Add
4. Return to HealthTrack AI
5. Go to **Health** tab → See glucose reading

### Test Gamification

1. Log 2-3 meals
2. Check home screen:
   - HP bar should increase
   - XP should increase
3. Go to **Trophies** tab
4. See "First Photo" trophy unlocked

## Common Issues

### ❌ Build Error: "GoogleService-Info.plist not found"

**Fix:**
```bash
# Verify file location
ls HealthTrackAI/HealthTrackAI/GoogleService-Info.plist

# If missing, download again from Firebase Console
# Go to Project Settings → Your iOS app → Download plist
```

### ❌ "Module 'Firebase' not found"

**Fix:**
1. File → Packages → Resolve Package Versions
2. Clean build folder: **Cmd + Shift + K**
3. Rebuild: **Cmd + B**

### ❌ Signing Error

**Fix:**
1. Xcode → Preferences → Accounts
2. Add your Apple ID if not present
3. Click **Download Manual Profiles**
4. Return to Signing & Capabilities → Select team again

### ❌ "This app requires HealthKit"

**Fix:**
- HealthKit only works on **physical devices**
- Test on iPhone (iOS 17+) instead of Simulator
- OR skip HealthKit features for now

### ❌ Simulator shows blank screen

**Fix:**
1. Stop app (**Cmd + .**)
2. Simulator → Device → Erase All Content and Settings
3. Run again (**Cmd + R**)

## Next Steps

### For Development

1. **Test all features** (15 min)
   - Complete user flow
   - Log multiple meals
   - Check health charts
   - View monthly plan
   - Explore trophies

2. **Customize branding** (30 min)
   - Change app name in scheme
   - Update colors in Assets
   - Add app icon

3. **Add food database** (1 hour)
   - Firebase Console → Firestore → food_database
   - Add 50-100 common foods
   - See README for structure

### For Production

1. **Set up In-App Purchases**
   - App Store Connect → Create subscriptions
   - Update product IDs in Constants.swift
   - Test with sandbox account

2. **Prepare App Store assets**
   - Take screenshots
   - Write description
   - Create app icon

3. **Submit for review**
   - Follow DEPLOYMENT.md guide
   - Typical wait: 24-48 hours

## Resources

- **Full Documentation:** README.md
- **Deployment Guide:** DEPLOYMENT.md
- **Firebase Console:** https://console.firebase.google.com
- **App Store Connect:** https://appstoreconnect.apple.com

## Need Help?

- Check README.md for detailed instructions
- Search issue on [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase+swiftui)
- Open issue on GitHub: [Create Issue]

---

**You're all set! Start building! 🚀**
