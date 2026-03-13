import 'package:flutter/foundation.dart';
import 'package:stts/stts.dart';
import 'package:logging/logging.dart';

import 'package:flap/pb/nostr.pb.dart' as pb;

class Speech extends ChangeNotifier {
  static Speech? _instance;
  Speech._() {
    // TODO:
  }
  factory Speech() {
    _instance ??= Speech._();
    return _instance!;
  }

  final log = Logger('Speech');
  final tts = Tts();
  String? voiceId;

  Future<void> speakNote(pb.Note note) async {
    await tts.stop();

    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.setRate(1.0);

    if (voiceId == null) {
      await _setVoice(note.lang);
    }
    await tts.start(note.content);
  }

  Future<void> _setVoice(String lang) async {
    await tts.setLanguage(lang);
    final voices = await tts.getVoicesByLanguage(lang);
    if (voices.isEmpty) {
      log.warning('a list of voices is empty');
      return;
    }
    String id = voices.first.id;
    final platform = defaultTargetPlatform.name;
    final list = voices.map((voice) => voice.id).toList();
    log.info('platform: $platform, voices: $list');
    switch (platform) {
      case 'macOS' || 'iOS':
        switch (lang) {
          case 'ja-JP':
            if (list.contains('O-Ren')) {
              id = 'O-Ren';
            } else if (list.contains('Kyoko')) {
              id = 'Kyoko';
            }
          case 'en-US':
            if (list.contains('Samantha')) {
              id = 'Samantha';
            }
          default:
        }
      default:
    }
    log.info('voice selected: $id');
    tts.setVoice(id);
    voiceId = id;
  }
}
