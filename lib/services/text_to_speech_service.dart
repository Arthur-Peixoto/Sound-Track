import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'audio_player_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TextToSpeechService {
  static final String EL_API_KEY = dotenv.env['EL_API_KEY'] as String;
  static bool isPortuguese = true;
  static String voice = 'tS45q0QcrDHqHoaWdCDR';
  static String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voice';

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

      String localFilePath = await AudioPlayerService.saveAudio(bytes, fileName);
      String firebaseUrl = await _uploadToFirebase(File(localFilePath), fileName);

      return firebaseUrl;
    } else {
      throw Exception('Failed to save audio');
    }
  }

  static Future<String> _uploadToFirebase(File file, String fileName) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket:"gs://soundtrack-11c18.appspot.com/audios/"
      );
      String storagePath = 'gs://soundtrack-11c18.appspot.com/audios/$fileName';
      Reference ref = storage.refFromURL(storagePath);

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload para Firebase: $e');
    }
  }
}
