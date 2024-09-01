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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu,),
            color: Colors.black87,
            onPressed: _toggleSidebar,
          ),
        ],
        title: const Text('Sound Track', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Row(
        children: [
          if (_isSidebarVisible)
            SideBar(onCollectionSelected: _onCollectionSelected, isVisible: _isSidebarVisible),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      labelText: 'Adicione algum texto',
                      labelStyle: TextStyle(color: Colors.deepPurple[700]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      _playTextToSpeech(_textFieldController.text);
                    },
                    icon: _isLoadingVoice
                        ? const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Icon(Icons.volume_up),
                    label: const Text('Reproduzir Texto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      primary: Colors.deepPurple[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      final firstAvailableIndex = savedAudioPaths.indexWhere((path) => path == null);
                      if (firstAvailableIndex != -1) {
                        _saveTextToSpeech(_textFieldController.text, firstAvailableIndex);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Todos os botões estão ocupados!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Áudio'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      primary: Colors.deepPurple[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          onPressed: savedAudioPaths[index] != null
                              ? () {
                            AudioPlayerService.playAudioFile(savedAudioPaths[index]!);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            primary: savedAudioPaths[index] != null
                                ? Colors.deepPurple[300]
                                : Colors.grey[400],
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          child: Text(
                            'Botãozinho ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
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
