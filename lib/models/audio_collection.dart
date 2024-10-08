import 'package:flutter/material.dart';

class AudioCollection {
  final String name;
  final DateTime dateCreated;
  final List<String> items;
  final Color color;
  List<String?>? emojiRepresentation;

  AudioCollection({
    required this.name,
    required this.items,
    required this.color,
    this.emojiRepresentation,
  }) : dateCreated = DateTime.now();
}