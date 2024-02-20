import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_merge_method_channel.dart';

abstract class AudioMergePlatform extends PlatformInterface {
  /// Constructs a AudioMergePlatform.
  AudioMergePlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioMergePlatform _instance = MethodChannelAudioMerge();

  /// The default instance of [AudioMergePlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioMerge].
  static AudioMergePlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioMergePlatform] when
  /// they register themselves.
  static set instance(AudioMergePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
