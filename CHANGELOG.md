# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-06-18

### Fixed
- Fixed a startup crash in Android release builds caused by R8 resource shrinking stripping the `notification_icon` drawable.

## [1.2.0] - 2026-06-18

### Added
- Real-time foreground sound chime when your username is mentioned.
- System push notifications for mentions when the app is minimized/in the background.
- Support for joining and switching between multiple active chat rooms simultaneously.
- Dynamic "host" badges inside active room lists to identify which rooms you created.
- Activated message notifications and mention sound toggles in the settings panel.

### Fixed
- Resolved issue in Identity Settings where the edit modals would not dismiss after saving.
- Resolved a startup race condition where preferred nickname and color preferences were not loaded in time before entering a room.
- Added timeouts to WebSocket room connection and discovery requests to prevent infinite loading spinners.
- Fixed WebSocket stability issues and implemented automatic reconnection with exponential backoff.

## [1.1.0] - 2026-06-18

### Added
- New terminal-themed app icons for mobile platforms.

## [1.0.0] - 2026-06-16

### Added
- Initial release of Termchat.
- Real-time minimal anonymous chatrooms with password protection.
- Live public room discovery page.
- Code-based room joining.
- Active users list sidebar drawer in rooms.
- Clean terminal-inspired UI with light/dark mode and customizable text sizes.
- MIT License file.
