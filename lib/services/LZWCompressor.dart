import 'dart:collection';

class LZWCompressor {
  // Função para comprimir a sequência de emojis
  List<int> compress(String input) {
    // Inicializa o dicionário com os caracteres únicos encontrados
    Map<String, int> dictionary = {};
    int dictSize = 0;

    // Inicializa o dicionário com cada caractere da entrada
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (!dictionary.containsKey(char)) {
        dictionary[char] = dictSize++;
      }
    }

    String current = '';
    List<int> result = [];

    for (int i = 0; i < input.length; i++) {
      String next = input[i];
      String combined = current + next;

      // Se o dicionário já contém a sequência combinada
      if (dictionary.containsKey(combined)) {
        current = combined;
      } else {
        // Adiciona o código da sequência anterior comprimido
        result.add(dictionary[current]!);
        // Adiciona a nova sequência ao dicionário
        dictionary[combined] = dictSize++;
        current = next;
      }
    }

    // Adiciona o restante da sequência
    if (current.isNotEmpty) {
      result.add(dictionary[current]!);
    }

    return result;
  }

  // Função para descomprimir a sequência de emojis
  String decompress(List<int> compressed, Map<int, String> initialDictionary) {
    Map<int, String> dictionary = Map.from(initialDictionary);
    int dictSize = initialDictionary.length;

    String current = dictionary[compressed[0]]!;
    StringBuffer result = StringBuffer(current);

    for (int i = 1; i < compressed.length; i++) {
      int code = compressed[i];
      String entry;

      if (dictionary.containsKey(code)) {
        entry = dictionary[code]!;
      } else if (code == dictSize) {
        entry = current + current[0];
      } else {
        throw Exception('Erro na descompressão.');
      }

      result.write(entry);

      // Adiciona a nova sequência ao dicionário
      dictionary[dictSize++] = current + entry[0];
      current = entry;
    }

    return result.toString();
  }
}

void main() {
  LZWCompressor compressor = LZWCompressor();

  String emojis = '😄😄🔥🔥💥💥💥😄🔥😄💥🔥';

  print('Sequência original: $emojis');

  // Compressão
  List<int> compressed = compressor.compress(emojis);
  print('Comprimido: $compressed');

  // Cria um dicionário inicial para descompressão
  Map<int, String> initialDictionary = {};
  for (int i = 0; i < emojis.length; i++) {
    if (!initialDictionary.containsValue(emojis[i])) {
      initialDictionary[initialDictionary.length] = emojis[i];
    }
  }

  // Descompressão
  String decompressed = compressor.decompress(compressed, initialDictionary);
  print('Descomprimido: $decompressed');
}
