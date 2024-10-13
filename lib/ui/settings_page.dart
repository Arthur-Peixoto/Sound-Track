import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/audio_player_service.dart';
import '../services/text_to_speech_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _volume = prefs.getDouble('volume') ?? 0.5; // Valor padrão é 0.5
    });
  }

  void _saveVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', _volume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Alterar Idioma'),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/brazil.png',
                      width: 32,
                      height: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        TextToSpeechService.isPortuguese = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/uk.png',
                      width: 32,
                      height: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        TextToSpeechService.isPortuguese = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.volume_up),
              title: Text('Ajustes de Volume'),
              subtitle: Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                divisions: 5,
                label: _volume.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                  AudioPlayerService.setVolume(_volume);
                  _saveVolume();
                },
              ),
            ),
            ListTile(
              title: Text('Escolher Voz'),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (TextToSpeechService.isPortuguese == true) {
                            TextToSpeechService.voice = 'FIEA0c5UHH9JnvWaQrXS';
                          } else {
                            TextToSpeechService.voice = '21m00Tcm4TlvDq8ikWAM';
                          }
                        });
                      },
                      icon: SvgPicture.asset(
                        'assets/female.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Feminina'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (TextToSpeechService.isPortuguese == true) {
                            TextToSpeechService.voice = 'tS45q0QcrDHqHoaWdCDR';
                          } else {
                            TextToSpeechService.voice = 'pNInz6obpgDQGcFmaJgB';
                          }
                        });
                      },
                      icon: SvgPicture.asset(
                        'assets/male.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Masculina'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
