# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Multi-room chat architecture: users can now join, manage, and switch between multiple active rooms simultaneously.
- Room discovery list view inside `RoomsPage` to switch active sessions.
- Password-protected room support via a custom `PasswordPromptModal`.
- Settings menu: customize nickname, preferred color, dark/light theme, and dynamic font scale.
- WebSocket connection exponential backoff reconnection logic (delays double up to 30s) in `ChatRepository`.
- Orange status banner in the chat UI indicating when reconnection is active.
- 10-second timeout constraints to WebSocket connections and rooms HTTP `/discover` endpoint to prevent indefinite hangs.
- Activated message notifications and mention sound toggles in settings.
- Centralized `ColorUtils` hex-to-color parser.
- Centralized `RoomJoinHelper` to unify and deduplicate room connection and routing logic.
- Dynamic `isHost` rendering on active session cards based on current user's nickname matched against active room user metadata.

### Changed
- Refactored `IdentityBloc` to use `@lazySingleton` ensuring a single eager state instance throughout the app and eliminating race conditions when joining rooms.
- Cleaned up obsolete sections and improved formatting in the `README.md`.
- Removed `isHost` attribute from the global `User` preferred identity model.

### Removed
- Unused `JoinRoom` events and associated `passwordRequired` states from `RoomsBloc` to reduce code surface.
- Unused/duplicated hex color parsing methods across widgets.
- Redundant and obvious comments across codebase.

## [1.1.0] - 2026-06-18

### Added
- Added custom terminal-themed app icons for the mobile application.

## [1.0.0] - 2026-06-16

### Added
- Initial full release of Termchat app.
- Real-time minimal anonymous chatrooms powered by WebSockets.
- Public room discovery list.
- Room code joining capabilities.
- Live active users list side drawer in chat.
- Clean minimal terminal-inspired UI design.
- MIT License file.
