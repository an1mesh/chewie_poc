# Chewie Kpoint

An Instagram-like vertical video feed application built with Flutter, featuring smooth video playback and an intuitive user interface.

## Features

- **Vertical Video Feed**: Scroll through videos vertically (Instagram Reels/TikTok style)
- **Video Playback**: Powered by Chewie video player with smooth playback
- **Video Controls**:
  - Tap anywhere on video to play/pause
  - Interactive progress bar in the bottom navigation bar
  - Seek through videos by tapping or dragging on the progress bar
  - Videos loop continuously
- **Instagram-style UI**:
  - Like, Comment, Share, and Bookmark buttons
  - User profile information overlay
  - Clean, modern interface
- **Bottom Navigation Bar**: Custom navigation bar with integrated video progress indicator

## Tech Stack

- **Flutter**: Cross-platform mobile framework
- **Chewie**: Advanced video player widget for Flutter
- **video_player**: Official Flutter video player plugin

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.1)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/main.dart`: Main application file containing the video feed and player implementation
- `pubspec.yaml`: Project dependencies and configuration

## Usage

- **Scroll**: Swipe up/down to navigate between videos
- **Play/Pause**: Tap anywhere on the video screen
- **Seek**: Tap or drag on the progress bar at the bottom
- **Interact**: Use the action buttons (like, comment, share) on the right side of each video

## Dependencies

- `chewie: ^1.8.1` - Video player widget
- `video_player: ^2.9.1` - Video playback functionality
- `flutter` - Core Flutter framework

## License

This project is a private application.
