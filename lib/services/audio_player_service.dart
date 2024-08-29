import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sound_track/models/my_custom_source.dart';

class AudioPlayerService {
  static final AudioPlayer player = AudioPlayer();

  static Future<void> playAudio(List<int> bytes) async {
    await player.setAudioSource(MyCustomSource(bytes));
    player.play();
  }

  static Future<void> playAudioFile(String filePath) async {
    await player.setFilePath(filePath);
    player.play();
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
