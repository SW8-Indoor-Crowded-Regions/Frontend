# indoor_crowded_regions_frontend

## Project Overview
This is the frontend for the Indoor Crowded Regions application, built using Flutter.

## Getting Started

To set up and run the project locally, follow these steps:

Clone the repository:

```
git clone https://github.com/SW8-Indoor-Crowded-Regions/Frontend.git
cd indoor_crowded_regions_frontend
```

Install dependencies:

```
flutter pub get
```

Create platform build:
```
flutter create .
```
or
```
flutter create --platforms=android .
```


Run the application (terminal):
```
flutter run
```

Run the application (vscode):

1. Go to main.dart
2. Press f5


## Requirements
- Flutter SDK (latest stable version recommended)

- Dart SDK

- Android Studio (for Android development)

- Xcode (for iOS development, if applicable)

## ❄️ NixOS ❄️
On NixOS you need to enter the flake using: 
```nix
nix develop
```
and create an emulator:
```bash
avdmanager create avd --force --name phone --package 'system-images;android-32;google_apis;x86_64'
emulator -avd phone -skin 720x1280 --gpu host
```
If it is first time building, then run: 
```bash
flutter create .
```
If not, then simply use run the emulator using 
```bash
flutter emulators --launch phone
```
And then run the application, while the emulator is running:
```bash
flutter run -d sdk
```


