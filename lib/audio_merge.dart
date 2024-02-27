import 'audio_merge_platform_interface.dart';

class AudioMerge {
  listen({
    Function(int)? onProgress,
    Function(String)? onSuccess,
  }) {
    AudioMergePlatform.instance.listen(
      onProgress: onProgress,
      onSuccess: onSuccess,
    );
  }

  Future<String?> mixAudio(Map<String, dynamic> data) {
    return AudioMergePlatform.instance.mixAudio(data);
  }

  Future<String?> getPlatformVersion() {
    return AudioMergePlatform.instance.getPlatformVersion();
  }
}
