import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'audio_player_service.dart';

import 'audio_player_service.dart';

class TextToSpeechService {
  static final String EL_API_KEY = dotenv.env['EL_API_KEY'] as String;
  static String voiceRachel = '21m00Tcm4TlvDq8ikWAM';
  static String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';
  static String voiceLax = 'tS45q0QcrDHqHoaWdCDR';
  static String urlLax = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceLax';

  static Future<void> playTextToSpeech(String text) async {


    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': EL_API_KEY,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": .15, "similarity_boost": .75}
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      await AudioPlayerService.playAudio(bytes);
    } else {
      throw Exception('Failed to load audio');
    }
  }

  static Future<String> saveTextToSpeech(String text, String fileName) async {
    String voiceRachel = '21m00Tcm4TlvDq8ikWAM';
    String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';


    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': EL_API_KEY,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": .15, "similarity_boost": .75}
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return await AudioPlayerService.saveAudio(bytes, fileName);
    } else {
      throw Exception('Failed to save audio');
    }
  }
}
