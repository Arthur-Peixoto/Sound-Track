import 'package:flutter/material.dart';
import 'package:sound_track/services/text_to_speech_service.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textFieldController = TextEditingController();
  bool _isLoadingVoice = false;

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

  Future<void> _saveTextToSpeech(String text) async {
    final filePath = await TextToSpeechService.saveTextToSpeech(text, 'output.mp3');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Audio saved to $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EL TTS Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(
                labelText: 'Enter some text',
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
                _saveTextToSpeech(_textFieldController.text);
              },
              child: const Text('Save Audio'),
            ),
          ],
        ),
      ),
    );
  }
}
