import 'package:flutter/material.dart';
import 'package:sound_track/services/collection_service.dart';
import 'package:sound_track/models/audio_collection.dart';

class SideBar extends StatefulWidget {
  final Function(AudioCollection) onCollectionSelected;
  final bool isVisible;

  SideBar({
    required this.onCollectionSelected,
    required this.isVisible,
  });

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  void _addNewCollection() {
    if (CollectionService.getCollection().length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 6 coleções atingido!')),
      );
      return;
    }

    String collectionName = '';
    Color collectionColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nova Coleção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => collectionName = value,
                decoration: InputDecoration(labelText: 'Nome da Coleção'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Escolha a cor:'),
                  const SizedBox(width: 8),
                  DropdownButton<Color>(
                    value: collectionColor,
                    onChanged: (Color? newValue) {
                      setState(() {
                        collectionColor = newValue!;
                      });
                    },
                    items: <Color>[Colors.blue, Colors.red, Colors.green, Colors.purple]
                        .map<DropdownMenuItem<Color>>((Color value) {
                      return DropdownMenuItem<Color>(
                        value: value,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: value,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                CollectionService.createNewCollection(collectionName, collectionColor);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isVisible
        ? Container(
      width: 200,
      color: Colors.grey[200],
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CollectionService.getCollection().length,
              itemBuilder: (context, index) {
                final collection = CollectionService.getCollection()[index];
                return ListTile(
                  title: Text(collection.name),
                  leading: CircleAvatar(
                    backgroundColor: collection.color,
                  ),
                  onTap: () {
                    widget.onCollectionSelected(collection);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _addNewCollection,
              child: const Text('Nova Coleção'),
            ),
          ),
        ],
      ),
    )
        : SizedBox.shrink(); // Retorna um widget vazio se não for visível
  }
}
