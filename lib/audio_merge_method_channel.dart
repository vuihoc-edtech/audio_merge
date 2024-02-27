// ignore_for_file: constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_merge_platform_interface.dart';

/// An implementation of [AudioMergePlatform] that uses method channels.
class MethodChannelAudioMerge extends AudioMergePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_merge');

  @override
  Future<void> listen({dynamic Function(int)? onProgress}) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'ON_PROGRESS':
          return onProgress?.call(call.arguments);
        default:
          return Future(() => null);
      }
    });
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      Method.GET_PLATFORM_VERSION.name,
    );
    return version;
  }

  @override
  Future<String?> mixAudio(Map<String, dynamic> data) {
    return methodChannel.invokeMethod<String>(
      Method.MERGE.name,
      data,
    );
  }
}

enum Method {
  MERGE,
  ON_PROGRESS,
  ON_SUCCESS,
  REQUEST_EXTERNAL_STORAGE,
  GET_PLATFORM_VERSION
}
