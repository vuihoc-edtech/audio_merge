import 'package:audio_merge/audio_merge_method_channel.dart';

import 'audio_merge_platform_interface.dart';

class AudioMerge {
  Future<String?> getPlatformVersion() {
    return AudioMergePlatform.instance.getPlatformVersion();
  }

  Future<void> onNativeCall({
    OnVideoMerged? onVideoMerged,
  }) async {
    return AudioMergePlatform.instance.onNativeCall(
      onVideoMerged: onVideoMerged,
    );
  }

  Future<String?> mergeAudio(List<Map> maps) =>
      AudioMergePlatform.instance.mergeAudio(maps);
}
