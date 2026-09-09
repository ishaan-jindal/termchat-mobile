import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  AudioHelper._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playMentionChime() async {
    try {
      await _player.play(AssetSource('mention_chime.wav'));
    } catch (_) {
      // Best-effort; ignore player errors.
    }
  }
}
