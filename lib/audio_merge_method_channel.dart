import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_merge_platform_interface.dart';

typedef OnVideoMerged = Function(String path);

/// An implementation of [AudioMergePlatform] that uses method channels.
class MethodChannelAudioMerge extends AudioMergePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_merge');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> onNativeCall({
    OnVideoMerged? onVideoMerged,
  }) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case AudioMergeConst.audioMerged:
          return onVideoMerged?.call(call.arguments);
        default:
          return Future(() => null);
      }
    });
  }

  @override
  Future<String?> mergeAudio(List<Map> maps) {
    final result =
        methodChannel.invokeMethod<String>(AudioMergeConst.mergeAudio, maps);
    return result;
  }
}

class AudioMergeConst {
  static const String mergeAudio = 'MERGE_AUDIO';

  // Native call
  static const String audioMerged = 'AUDIO_MERGED';
}
