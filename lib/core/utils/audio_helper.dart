import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  AudioHelper._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playMentionChime() async {
    try {
      await _player.play(AssetSource('mention_chime.wav'));
    } catch (_) {
      // Ignore audio playing errors to avoid crashing the app on unsupported platforms
    }
  }
}
