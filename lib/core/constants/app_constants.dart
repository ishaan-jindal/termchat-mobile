class AppConstants {
  AppConstants._();

  // --- App Info ---
  static const String appName = 'termchat';
  static String appVersion = '';
  static const String appDescription = 'minimal anonymous chatrooms';

  // --- API ---
  static const String apiHost = String.fromEnvironment(
    'TERMCHAT_API_HOST',
    defaultValue: 'termchat.sacred99.online',
  );
  static const String apiBaseUrl = 'https://$apiHost';
  static const String wsBaseUrl = 'wss://$apiHost/ws';
  static const String mediaWsBaseUrl = 'wss://$apiHost/media';

  static const String discoverPath = '/discover';
  static const Duration httpTimeout = Duration(seconds: 10);

  // --- Timeouts ---
  static const Duration wsJoinTimeout = Duration(seconds: 10);
  static const Duration mediaTokenTimeout = Duration(seconds: 5);
  static const Duration roomJoinTimeout = Duration(seconds: 15);
  static const Duration mediaConnectTimeout = Duration(seconds: 10);
  static const Duration voiceHandshakeTimeout = Duration(seconds: 10);
  static const Duration voicePipelineTimeout = Duration(seconds: 5);

  // ── Spacing ──
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing14 = 14;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  // ── Border Radius ──
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
}
