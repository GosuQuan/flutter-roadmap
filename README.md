# My Flutter App

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

- Flutter SDK
- Xcode (for iOS development)
- CocoaPods

### Installation

1. Install CocoaPods (if not installed):

```bash
brew install cocoapods
```

2. Install project dependencies:

```bash
flutter pub get
```

### Running the App

1. Start iOS Simulator:

```bash
open -a Simulator
```

2. To run the app in debug mode:

```bash
flutter run
```

### Common Commands

- Clean the project:

```bash
flutter clean
```

- Rebuild iOS project:

```bash
flutter build ios --no-codesign
```

- Check Flutter installation and dependencies:

```bash
flutter doctor
```

### Development

The main application code is in the `lib` directory:

- `lib/main.dart` - Application entry point
- `lib/screens/` - Application screens
- `lib/widgets/` - Reusable widgets
- `lib/models/` - Data models
- `lib/services/` - Business logic and services

### Resources

- [Flutter d](https://docs.flutter.dev)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

### Checking if Simulator is Running

```bash
xcrun simctl list devices available

$ flutter run -d 47A424F0-EDF6-4E78-B1A1-5543EDADD5A2

```
