# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## Unreleased

### Added
- Message reactions: long-press a message to open a picker and tap a chip to toggle a reaction;
  reactions show counts and highlight the ones you've selected, and the last reaction on a message can now be fully removed.
  (by @ishaan-jindal)
- Reply to messages by swiping right on a message, with haptic feedback;
  the reply target is shown in the input area and cleared when the message is sent or canceled. (by @ishaan-jindal)
- Terminal-style message bubbles: rounded surface with a sender-colored left accent stripe and a `> nick` prompt. (by @ishaan-jindal)
- Adopted server-assigned message IDs and plumbed reaction/reply models end-to-end. (by @ishaan-jindal)
- Push-to-talk voice chat: join a room's voice session from the chat top bar, hold the mic button to talk (or lock it on for hands-free), and see `[vc]` badges next to users in voice. Audio streams as 16 kHz mono PCM over the `/media` socket, is mixed per speaker, uses echo cancellation, and automatically rejoins if the voice connection drops. (by @ishaan-jindal)

### Changed
- Notification permission is now requested via `permission_handler` after the first frame; the Settings panel shows the OS permission state and re-requests permission when you turn on message notifications. (by @ishaan-jindal)

### Fixed
- The Android 13+ notification permission prompt now actually appears (`POST_NOTIFICATIONS` is declared in the manifest; previously the request silently failed). (by @ishaan-jindal)

## [1.3.1] - 2026-07-10

### Fixed
- GitHub Actions release workflow now correctly strips the `+build` suffix before matching CHANGELOG section headers.
- Corrected release artifact upload name from stale `download-manager` prefix to `termchat`.

## [1.3.0] - 2026-07-02

### Added
- Comprehensive test suite with 90+ unit tests across models, BLoCs, and repositories.
- Auto-refresh for the "rooms online now" list every 30 seconds.
- Dependabot configuration for automated dependency updates.
- Contribution guidelines (`CONTRIBUTING.md`).

### Changed
- Joining a room now waits for a successful connection before navigating to the chat screen. On failure (wrong password, invalid code, timeout) a clear error snackbar is shown instead.
- Room code input now validates for exactly 4 uppercase alphanumeric characters, with inline error feedback.
- Password prompt modal now returns the password as a result instead of calling an `onJoin` callback.
- Join room text inputs are cleared after a successful join.
- `RoomJoinHelper.joinRoom` is now async and returns `bool` indicating success.
- Extracted network DTOs from `core/models/` into `data/models/` split by type.
- Moved the app shell from `features/main/` to `core/layout/` and renamed `MainLayout` → `ShellLayout`.
- Updated README with improved project description and links.

### Fixed
- Chat history messages are now batched and replace the state atomically instead of being appended one by one.
- Chat page now navigates back on connection failure instead of showing a stuck broken page.
- `/nick` and `/color` commands now persist locally before sending over the wire.
- Message timestamps now use server-provided unix millis timestamps instead of `DateTime.now()`.
- Chat input maintains keyboard focus after sending a message.

### Removed
- Removed unused `theme_cubit.dart` and stub `joinRoom`/`leaveRoom` repository methods.
- Removed direct `getIt()` calls from widgets (replaced with `context.read()` via `RepositoryProvider`).
- Removed redundant `/nick`/`/color` handling from `chat_page.dart` (handled in `ChatBloc`).
- Injected `IdentityBloc` and `SettingsBloc` into `ChatBloc` constructor instead of `getIt()` lookups.

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
