import 'package:flutter/material.dart';
import 'package:sound_track/services/audio_player_service.dart';
import 'package:sound_track/services/text_to_speech_service.dart';
import 'package:sound_track/ui/side_bar.dart';
import 'package:sound_track/models/audio_collection.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textFieldController = TextEditingController();
  bool _isLoadingVoice = false;
  bool _isSidebarVisible = false;
  List<String?> savedAudioPaths = List.filled(8, null); // Lista para armazenar os caminhos dos áudios salvos
  AudioCollection? selectedCollection;

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _playTextToSpeech(String text) async {
    setState(() {
      _isLoadingVoice = true;
    });

    await TextToSpeechService.playTextToSpeech(text);

    setState(() {
      _isLoadingVoice = false;
    });
  }

  Future<void> _saveTextToSpeech(String text, int index) async {
    final filePath = await TextToSpeechService.saveTextToSpeech(text, 'output$index.mp3');
    setState(() {
      savedAudioPaths[index] = filePath;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Áudio salvo no botão ${index + 1}')),
    );
  }

  void _onCollectionSelected(AudioCollection collection) {
    setState(() {
      selectedCollection = collection;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coleção ${collection.name} selecionada')),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_isSidebarVisible ? Icons.table_rows : Icons.table_rows),
            onPressed: _toggleSidebar,
          ),
        ],
        title: const Text('Sound Track'),
      ),
      body: Row(
        children: [
          if (_isSidebarVisible) SideBar(onCollectionSelected: _onCollectionSelected, isVisible: _isSidebarVisible),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _textFieldController,
                    decoration: const InputDecoration(
                      labelText: 'Adicione algum texto',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _playTextToSpeech(_textFieldController.text);
                    },
                    child: _isLoadingVoice
                        ? const LinearProgressIndicator()
                        : const Icon(Icons.volume_up),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Salva no primeiro botão disponível
                      final firstAvailableIndex = savedAudioPaths.indexWhere((path) => path == null);
                      if (firstAvailableIndex != -1) {
                        _saveTextToSpeech(_textFieldController.text, firstAvailableIndex);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Todos os botões estão ocupados!')),
                        );
                      }
                    },
                    child: const Text('Salvar Audio'),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          onPressed: savedAudioPaths[index] != null
                              ? () {
                            AudioPlayerService.playAudioFile(savedAudioPaths[index]!);
                          }
                              : null,
                          child: Text('Botãozinho ${index + 1}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
