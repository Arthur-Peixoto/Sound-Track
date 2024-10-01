import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sound_track/services/audio_player_service.dart';
import 'package:sound_track/services/text_to_speech_service.dart';
import 'package:sound_track/ui/side_bar.dart';
import 'package:sound_track/models/audio_collection.dart';
import 'package:sound_track/services/collection_service.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textFieldController = TextEditingController();
  bool _isLoadingVoice = false;
  bool _isSidebarVisible = false;
  AudioCollection? selectedCollection;

  @override
  void initState() {
    super.initState();
    if (CollectionService.getCollection().isEmpty) {
      CollectionService.createNewCollection('Coleção Padrão', Colors.blue);
    }
    selectedCollection = CollectionService.getCollection().first;
  }

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

  Future<void> _saveTextToSpeech(String text, int index, String emoji) async {
    if (selectedCollection != null) {
      final fileName = 'output_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final filePath = await TextToSpeechService.saveTextToSpeech(text, fileName);

      // Salva o áudio e o emoji diretamente
      if (index < selectedCollection!.items.length) {
        selectedCollection!.items[index] = filePath;
      } else {
        selectedCollection!.items.add(filePath);
      }

      setState(() {
        // Salva o emoji diretamente como String
        selectedCollection!.emojiRepresentation ??= List.filled(8, null);
        selectedCollection!.emojiRepresentation![index] = emoji;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Áudio salvo no botão ${index + 1} da coleção ${selectedCollection!.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma coleção antes de salvar o áudio.')),
      );
    }
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

  Future<void> _selectEmojiAndSave(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolha um emoji para o áudio'),
          content: Container(
            width: 300,
            height: 400,
            child: SingleChildScrollView( // Usando SingleChildScrollView para evitar problemas com conteúdo grande
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      Navigator.of(context).pop();
                      _saveTextToSpeech(_textFieldController.text, index, emoji.emoji);
                    },
                    config: Config(
                      height: 300,
                      emojiTextStyle: TextStyle(fontSize: 20),
                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 24.0,
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        indicatorColor: Colors.deepPurple,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.deepPurple,
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(
                        enabled: true,
                        showBackspaceButton: true,
                        showSearchViewButton: true,
                        backgroundColor: Colors.deepPurple,
                        buttonColor: Colors.deepPurple,
                        buttonIconColor: Colors.white,
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: const Color(0xFFEBEFF2),
                        buttonColor: Colors.transparent,
                        buttonIconColor: Colors.black26,
                        hintText: 'Pesquise um emoji',
                      ),
                      checkPlatformCompatibility: true,
                      swapCategoryAndBottomBar: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                      backgroundColor: Colors.deepPurple[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  if (selectedCollection != null)
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final audioPath = index < selectedCollection!.items.length
                              ? selectedCollection!.items[index]
                              : null;
                          String emoji = 'Botão ${index + 1}';
                          if (selectedCollection!.emojiRepresentation != null &&
                              selectedCollection!.emojiRepresentation![index] != null) {
                            emoji = selectedCollection!.emojiRepresentation![index]!;
                          }

                          return ElevatedButton(
                            onPressed: audioPath != null
                                ? () {
                              AudioPlayerService.playAudioFile(audioPath);
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: audioPath != null
                                  ? Colors.deepPurple[300]
                                  : Colors.grey[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.all(16.0),
                            ),
                            child: Text(
                              emoji,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      final firstAvailableIndex = selectedCollection!.items.length < 8
                          ? selectedCollection!.items.length
                          : -1;
                      if (firstAvailableIndex != -1) {
                        _selectEmojiAndSave(firstAvailableIndex);
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
                      backgroundColor: Colors.deepPurple[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
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
