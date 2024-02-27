import 'dart:async';
import 'dart:developer';

import 'package:audio_merge/audio_merge.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

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
  String _outputPath = '';
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _audioMergePlugin.listen(
      onProgress: (p) => mounted ? setState(() => _progress = p) : null,
    );
    getApplicationDocumentsDirectory().then((value) {
      _outputPath = '${value.path}/output.mp3';
    });
  }

  Future<void> initPlatformState() async {
    player.positionStream.listen((event) {
      setState(() => duration = event);
    });
  }

  Duration? duration;

  final player = AudioPlayer();

  String? background;
  List<String> voiceOvers = [];
  final _allowedExtensions = ['mp3', 'wav', 'aac', 'm4a'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Audio mixer example')),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(background ?? 'Background Music'),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: _allowedExtensions,
                      );
                      if (result != null) {
                        setState(() {
                          background = result.files.single.path;
                        });
                      }
                    },
                    child: const Text('Pick Background Music'),
                  ),
                  const SizedBox(height: 10),
                  Text(voiceOvers.join('\n')),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: _allowedExtensions,
                        allowMultiple: true,
                      );

                      if (result != null) {
                        setState(() {
                          voiceOvers =
                              result.paths.whereType<String>().toList();
                        });
                      }
                    },
                    child: const Text('Pick Voice Over'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final sw = Stopwatch();
                  sw.start();
                  final result = await _audioMergePlugin.mixAudio({
                    "background": background,
                    "output_path": _outputPath,
                    "script": {
                      ...{
                        for (var e in voiceOvers)
                          (voiceOvers.indexOf(e) * 3000): e
                      },
                    }
                  });
                  log('${sw.elapsed.inSeconds}', name: 'TIME TAKEN');
                  sw.stop();
                  setState(() => _outputPath = result ?? '');
                },
                child: Text('Start Mixing $_progress%'),
              ),
              const Divider(thickness: 2, color: Colors.black, height: 30),
              Text('OUTPUT:\n$_outputPath'),
              const SizedBox(height: 10),
              const Divider(thickness: 2, color: Colors.black, height: 30),
              _buildIndicator(),
              _buildDuration(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPlay(),
                  const SizedBox(width: 20),
                  _buildStop(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStop() {
    return ElevatedButton(
      onPressed: player.stop,
      style: ElevatedButton.styleFrom(primary: Colors.red),
      child: const Text('Stop'),
    );
  }

  Widget _buildPlay() {
    return ElevatedButton(
      onPressed: () async {
        if (_outputPath.isEmpty) return;
        await player.setFilePath(_outputPath);
        player.play();
      },
      child: const Text('Start'),
    );
  }

  SizedBox _buildDuration() {
    return SizedBox(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${duration ?? Duration.zero}'),
          Text('${player.duration ?? Duration.zero}'),
        ],
      ),
    );
  }

  SizedBox _buildIndicator() {
    return SizedBox(
      width: 300,
      child: LinearProgressIndicator(
        minHeight: 20,
        color: Colors.green,
        backgroundColor: Colors.green.withOpacity(0.3),
        value: (duration?.inMilliseconds ?? 0) /
            (player.duration?.inMilliseconds ?? 1),
      ),
    );
  }
}
