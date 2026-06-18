class AppConstants {
  AppConstants._();

  // --- App Info ---
  static const String appName = 'termchat';
  static const String appVersion = '1.2.1';
  static const String appDescription = 'minimal anonymous chatrooms';

  // --- API ---
  static const String apiHost = 'termchat.sacred99.online';
  static const String apiBaseUrl = 'https://$apiHost';
  static const String wsBaseUrl = 'wss://$apiHost/ws';

  // ── Spacing ──
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing14 = 14;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing28 = 28;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  // ── Border Radius ──
  static const double radius4 = 4;
  static const double radius6 = 6;
  static const double radius8 = 8;
  static const double radius10 = 10;
  static const double radius12 = 12;
  static const double radius16 = 16;

  // ── Breakpoints ──
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
}
