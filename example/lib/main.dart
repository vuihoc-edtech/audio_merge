import 'package:audio_merge/audio_merge.dart';
import 'package:flutter/material.dart';

class AudioModel {
  final int index;
  final String pathAudio;

  AudioModel({
    required this.index,
    required this.pathAudio,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'index': index,
        'path_audio': pathAudio,
      };
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _audioMergePlugin = AudioMerge();

  @override
  void initState() {
    super.initState();
    _audioMergePlugin.onNativeCall(
      onVideoMerged: (path) {
        print('Video merged at $path');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: GestureDetector(
            onTap: () {
              final maps = [
                AudioModel(index: 0, pathAudio: 'assets/audio1.mp3'),
                AudioModel(index: 1, pathAudio: 'assets/audio2.mp3'),
                AudioModel(index: 2, pathAudio: 'assets/audio3.mp3'),
              ].map((e) => e.toJson()).toList();
              _audioMergePlugin.mergeAudio(maps);
            },
            child: const Text('play Merge Audio'),
          ),
        ),
      ),
    );
  }
}
