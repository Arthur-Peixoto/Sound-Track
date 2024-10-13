import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/my_custom_source.dart';

class AudioPlayerService {
  static final AudioPlayer player = AudioPlayer();

  static Future<void> playAudio(List<int> bytes) async {
    await player.setAudioSource(MyCustomSource(bytes));
    player.play();
  }

  static Future<void> playAudioFile(String filePath) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'gs://soundtrack-11c18.appspot.com',
      );

      final ref = storage.ref().child(filePath);
      String url = await ref.getDownloadURL();

      // Carregar a URL no player
      await player.setUrl(url);
      await player.play();
    } catch (e) {
      print("Erro ao reproduzir o áudio: $e");
    }
  }

  static Future<void> setVolume(double volume) async {
    player.setVolume(volume);
  }

  static Future<String> saveAudio(List<int> bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  static void dispose() {
    player.dispose();
  }
}
