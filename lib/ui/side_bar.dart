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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text('Nova Coleção', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => collectionName = value,
                decoration: InputDecoration(
                  labelText: 'Nome da Coleção',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Escolha a cor:'),
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
                          decoration: BoxDecoration(
                            color: value,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.black12),
                          ),
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
              child: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold)),
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
      width: 220,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 6.0,
          ),
        ],
      ),
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
                    child: Icon(Icons.audiotrack, color: Colors.white),
                  ),
                  onTap: () {
                    widget.onCollectionSelected(collection);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: _addNewCollection,
              icon: const Icon(Icons.add),
              label: const Text('Nova Coleção'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        : SizedBox.shrink(); // Retorna um widget vazio se não for visível
  }
}
