import 'dart:ui';

import 'package:sound_track/models/audio_collection.dart';

class CollectionService {
  static final List<AudioCollection> _collections = [];

  static void addToCollection(AudioCollection collection, String audioPath) {
    collection.items.add(audioPath);
  }

  static void removeFromCollection(AudioCollection collection, String audioPath) {
    collection.items.remove(audioPath);
  }

  static List<AudioCollection> getCollection() {
    return _collections;
  }

  static void createNewCollection(String name, Color color) {
    if (_collections.length < 6) {
      _collections.add(AudioCollection(name: name, items: [], color: color));
    }
  }
}
