import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../wordmodel.dart';
import '../constants.dart';

class WordRepository {
  // Singleton pattern preserved
  static final WordRepository _instance = WordRepository._internal();
  factory WordRepository() => _instance;
  WordRepository._internal();

  // BUCKET: Lexis Pro (Advanced/Exam Words)
  final List<String> _lexisProWords = [
    'Alacrity', 'Anomalous', 'Belligerent', 'Capricious', 'Diatribe', 
    'Ephemeral', 'Garrulous', 'Iconoclast', 'Laconic', 'Magnanimous',
    'Nefarious', 'Obsequious', 'Paradigm', 'Quixotic', 'Reticent',
    'Sycophant', 'Taciturn', 'Ubiquitous', 'Vacillate', 'Zealot', 
    'Abstemious', 'Banal', 'Cacophony', 'Ennui', 'Foment',
    'Guile', 'Jovial', 'Kudos', 'Loquacious', 'Meticulous',
    'Nadir', 'Paucity', 'Salubrious', 'Venerate', 'Wary', 
    'Xenophobic', 'Yoke', 'Amalgamate', 'Castigate', 'Demur', 
    'Equivocal', 'Inchoate', 'Ablution', 'Abnegation', 'Abstruse', 
    'Acrimonious', 'Adroit', 'Adulterate', 'Aesthete', 'Alloy', 
    'Ambivalence', 'Ameliorate', 'Amenable', 'Amorphous', 'Anachronism', 
    'Anathema', 'Ancillary', 'Antipathy', 'Apocryphal', 'Apostate', 
    'Approbation', 'Archaic', 'Arduous', 'Ascetic', 'Asperity', 
    'Assiduous', 'Assuage', 'Astringent', 'Atrophy', 'Attenuate', 
    'August', 'Austere', 'Avarice', 'Belie', 'Benign', 'Bolster', 
    'Bombastic', 'Boorish', 'Burnish', 'Calumny', 'Caustic', 
    'Chary', 'Circumspect', 'Coalesce', 'Complaisant', 'Confound', 
    'Connoisseur', 'Contrite', 'Convoluted', 'Craven', 'Decorum', 
    'Deference', 'Delineate', 'Denigrate', 'Derision', 'Derivative', 
    'Desultory', 'Diaphanous', 'Dictum', 'Didactic', 'Disabuse', 
    'Discerning', 'Discordant', 'Discrepancy', 'Disingenuous', 
    'Disparate', 'Dissemble', 'Dissonance', 'Distend', 'Docile', 
    'Dogmatic', 'Duplicity', 'Eclectic', 'Efficacy', 'Elegy', 
    'Elicit', 'Embellish', 'Emulate', 'Endemic', 'Enervate', 
    'Engender', 'Erudite', 'Esoteric', 'Eulogy', 'Euphemism', 
    'Exculpate', 'Exigency', 'Extrapolate', 'Fallow', 'Fatuous', 
    'Fawn', 'Felicitous', 'Fervid', 'Flag', 'Florid', 'Flout', 
    'Forestall', 'Fortuitous', 'Fractious', 'Frugality', 'Fulminate', 
    'Furtive', 'Gainsay', 'Goad', 'Gouge', 'Grandiloquent', 'Gullible', 
    'Harangue', 'Homogeneous', 'Hyperbole', 'Idolatry', 'Immutable', 
    'Impair', 'Impassive', 'Impede', 'Impermeable', 'Imperturbable', 
    'Impervious', 'Implacable', 'Implicit', 'Implode', 'Inadvertently', 
    'Incongruity', 'Inconsequential', 'Incorporate', 'Indeterminate', 
    'Indigence', 'Indolent', 'Inert', 'Ingenuous', 'Inherent', 
    'Innocuous', 'Insensible', 'Insinuate', 'Insipid', 'Insularity', 
    'Intractable', 'Intransigence', 'Inundate', 'Inured', 'Invective', 
    'Irascible', 'Irresolute', 'Itinerate', 'Latent', 'Laud', 
    'Lethargic', 'Levee', 'Levity', 'Log', 'Lucid', 'Magnanimity', 
    'Malingerer', 'Malleable', 'Maverick', 'Metamorphosis', 
    'Misanthrope', 'Mitigate', 'Mollify', 'Morose', 'Mundane', 
    'Negate', 'Neophyte', 'Obdurate', 'Obviate', 'Occlude', 
    'Officious', 'Onerous', 'Opprobrium', 'Oscillate', 'Ostentatious', 
    'Paragon', 'Partisan', 'Pathological', 'Pedantic', 'Penchant', 
    'Penury', 'Perennial', 'Perfidious', 'Perfunctory', 'Permeable', 
    'Pervasive', 'Phlegmatic', 'Piety'
  ];

  /// --- NEW: Word of the Day Logic (Consistent for 24h) ---
  Future<WordData?> fetchWordOfTheDay() async {
    try {
      if (_lexisProWords.isEmpty) return null;

      // Use the day of the year as a seed so the word only changes at midnight
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      
      // Select word based on index
      final index = dayOfYear % _lexisProWords.length;
      final dailyWord = _lexisProWords[index];

      // Return the full details from the dictionary API
      return await fetchWordDetails(dailyWord);
    } catch (e) {
      debugPrint("Word of the Day Error: $e");
      return null;
    }
  }

  /// --- Lexis Pro: Fetches curated words with a daily limit ---
  Future<List<WordData>> fetchLexisProWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      int count = prefs.getInt('pro_view_count') ?? 0;
      String lastDate = prefs.getString('last_pro_date') ?? "";

      if (lastDate != today) {
        count = 0;
        await prefs.setString('last_pro_date', today);
        await prefs.setInt('pro_view_count', 0);
      }

      if (count >= 20) {
        throw Exception("Daily limit reached. New Lexis Pro words will load tomorrow. Look at default words for now!");
      }

      _lexisProWords.shuffle();
      List<String> selection = _lexisProWords.take(4).toList();
      
      List<WordData?> results = await Future.wait(
        selection.map((word) => fetchWordDetails(word))
      );

      try {
        final randomWords = await fetchDailyWords();
        if (randomWords.isNotEmpty) {
          results.add(randomWords.first);
        }
      } catch (_) {}

      final finalResults = results.whereType<WordData>().toList();
      await prefs.setInt('pro_view_count', count + finalResults.length);
      
      return finalResults;
    } catch (e) {
      debugPrint("Lexis Pro Error: $e");
      rethrow;
    }
  }

  /// --- Fetches random daily words from API ---
  Future<List<WordData>> fetchDailyWords() async {
    try {
      final randomRes = await http.get(Uri.parse(AppConstants.randomWordApi))
          .timeout(const Duration(seconds: 10));

      if (randomRes.statusCode != 200) {
        throw Exception('Failed to fetch random words');
      }

      List<String> rawWords = List<String>.from(json.decode(randomRes.body));
      List<String> candidates = rawWords.where((w) => w.length > 4).take(8).toList();

      List<WordData?> results = await Future.wait(
        candidates.map((word) => fetchWordDetails(word))
      );

      return results.whereType<WordData>().toList();
    } catch (e) {
      debugPrint("Repository Error: $e");
      throw Exception('Network error: $e');
    }
  }

  /// --- Core Lookup: Dictionary API ---
  Future<WordData?> fetchWordDetails(String word) async {
    try {
      final res = await http.get(Uri.parse('${AppConstants.dictionaryApi}$word'))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(res.body)[0];
        return WordData.fromJson(data);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}