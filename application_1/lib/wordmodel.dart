class WordData {
  final String word;
  final String? phonetic;
  final String meaning;
  final String? example;
  final List<String> synonyms;
  bool isFavorite; // Add this line

  WordData({
    required this.word,
    this.phonetic,
    required this.meaning,
    this.example,
    this.synonyms = const [],
    this.isFavorite = false, // Add this default value
  });

  factory WordData.fromJson(Map<String, dynamic> json) {
    var meanings = json['meanings'][0];
    var definitions = meanings['definitions'][0];
    
    return WordData(
      word: json['word'],
      phonetic: json['phonetic'] ?? '',
      meaning: definitions['definition'] ?? 'No definition available',
      example: definitions['example'],
      synonyms: List<String>.from(meanings['synonyms'] ?? []),
      isFavorite: false, // Default to false when loaded from API
    );
  }
}