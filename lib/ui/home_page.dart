import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    if (text.trim().isEmpty) {
      _showSnackBar('Por favor, adicione algum texto.');
      return;
    }

    try {
      setState(() {
        _isLoadingVoice = true;
      });
      await TextToSpeechService.playTextToSpeech(text);
    } catch (e) {
      _showSnackBar('Falha ao reproduzir o áudio: $e');
    } finally {
      setState(() {
        _isLoadingVoice = false;
      });
    }
  }

  Future<void> _saveTextToSpeech(String text, int index, String emoji) async {
    if (selectedCollection == null) {
      _showSnackBar('Por favor, selecione uma coleção antes de salvar o áudio.');
      return;
    }

    final fileName = 'output_${DateTime.now().millisecondsSinceEpoch}.mp3';
    try {
      final filePath = await TextToSpeechService.saveTextToSpeech(text, fileName);

      setState(() {
        if (index < selectedCollection!.items.length) {
          selectedCollection!.items[index] = filePath;
        } else {
          selectedCollection!.items.add(filePath);
        }

        selectedCollection!.emojiRepresentation ??= List.filled(8, null);
        selectedCollection!.emojiRepresentation![index] = emoji;
      });

      _showSnackBar('Áudio salvo no botão ${index + 1} da coleção ${selectedCollection!.name}');
    } catch (e) {
      _showSnackBar('Falha ao salvar o áudio: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? 3 : 2;
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

  void _showSettingsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configurações'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Alterar Idioma'),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/brazil.png',
                        width: 32,
                        height: 32,
                      ), // Bandeira do Brasil

                      onPressed: () {
                        TextToSpeechService.isPortuguese = true;
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/uk.png',
                        width: 32,
                        height: 32,
                      ), // Bandeira do Reino Unido
                      onPressed: () {
                        TextToSpeechService.isPortuguese = false;
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.volume_up),
                title: Text('Ajustes de Volume'),
                subtitle: Slider(
                  value: 0.5,
                  onChanged: (value) {
                    // Ação para ajustar o volume do áudio
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
                          if(TextToSpeechService.isPortuguese == true){
                            TextToSpeechService.voice = 'FIEA0c5UHH9JnvWaQrXS';
                          }
                          else{
                            TextToSpeechService.voice = '21m00Tcm4TlvDq8ikWAM';
                          }
                        },
                        icon: SvgPicture.asset(
                          'assets/female.svg', // Substitua pelo caminho da imagem SVG feminina
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
                          if(TextToSpeechService.isPortuguese == true){
                            TextToSpeechService.voice = 'tS45q0QcrDHqHoaWdCDR';
                          }
                          else{
                            TextToSpeechService.voice = 'pNInz6obpgDQGcFmaJgB';
                          }
                        },
                        icon: SvgPicture.asset(
                          'assets/male.svg', // Substitua pelo caminho da imagem SVG masculina
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
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
            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
            color: Colors.black87,
            onPressed: _toggleSidebar,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.black87,
            onPressed: _showSettingsPopup,
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
                    onPressed: () => _playTextToSpeech(_textFieldController.text),
                    icon: _isLoadingVoice
                        ? const CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Icon(Icons.volume_up),
                    label: const Text('Reproduzir Texto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.deepPurple[800],
                      foregroundColor: Colors.white60,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  if (selectedCollection != null)
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _calculateCrossAxisCount(context),
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final audioPath = index < selectedCollection!.items.length ? selectedCollection!.items[index] : null;
                          String emoji = 'Botão ${index + 1}';
                          if (selectedCollection!.emojiRepresentation != null &&
                              selectedCollection!.emojiRepresentation![index] != null) {
                            emoji = selectedCollection!.emojiRepresentation![index]!;
                          }

                          return ElevatedButton(
                            onPressed: audioPath != null
                                ? () => AudioPlayerService.playAudioFile(audioPath)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: audioPath != null ? Colors.deepPurple[300] : Colors.grey[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              padding: const EdgeInsets.all(16.0),
                            ),
                            child: Text(emoji, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      final firstAvailableIndex = selectedCollection!.items.length < 8 ? selectedCollection!.items.length : -1;
                      if (firstAvailableIndex != -1) {
                        _selectEmojiAndSave(firstAvailableIndex);
                      } else {
                        _showSnackBar('Todos os botões estão ocupados!');
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Áudio'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.deepPurple[900],
                      foregroundColor: Colors.white60,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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

