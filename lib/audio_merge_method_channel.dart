import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_merge_platform_interface.dart';

/// An implementation of [AudioMergePlatform] that uses method channels.
class MethodChannelAudioMerge extends AudioMergePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_merge');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
