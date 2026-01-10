import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart'; // REQUIRED

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final FlutterTts _tts = FlutterTts(); // Centralized TTS
  static bool _isEnabled = false; 

  static bool get isEnabled => _isEnabled;

  static final List<AudioSource> _tracks = [
    AudioSource.asset('assets/music/dark-ambient.mp3'),
    AudioSource.asset('assets/music/medieval-ambient.mp3'),
    AudioSource.asset('assets/music/sci-fi-ambient.mp3'),
  ];

  static final List<String> trackNames = [
    'Dark Ambient',
    'Medieval Atmosphere',
    'Sci-Fi Soundscape',
  ];

  static Future<void> initAudio() async {
    try {
      // 1. Music Setup
      await _player.setAudioSource(_tracks[0], preload: false);
      await _player.setLoopMode(LoopMode.one); 

      // 2. TTS Setup (Standardizing for all Androids)
      var engines = await _tts.getEngines;
      if (engines.contains("com.google.android.tts")) {
        await _tts.setEngine("com.google.android.tts");
      }
      
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.45);  // Normalized speed
      await _tts.setPitch(1.0);        // Natural tone
      
    } catch (e) {
      debugPrint("Audio init error: $e");
    }
  }

  // Unified speak method
  static Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      await _tts.stop(); 
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  static Future<void> toggleMusic(bool status) async {
    _isEnabled = status;
    try {
      if (_isEnabled) {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        _player.play();
      } else {
        await _player.pause();
      }
    } catch (e) {
      debugPrint("Toggle error: $e");
    }
  }

  static Future<void> selectTrack(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    try {
      if (_player.playing) {
          await _player.stop();
      }
      await _player.setAudioSource(_tracks[index]);
      await _player.setLoopMode(LoopMode.one);
      if (_isEnabled) {
        _player.play();
      }
    } catch (e) {
      debugPrint("Track selection error: $e");
    }
  }

  static void dispose() {
    _player.dispose();
    _tts.stop();
  }
}