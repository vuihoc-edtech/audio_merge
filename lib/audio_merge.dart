
import 'audio_merge_platform_interface.dart';

class AudioMerge {
  Future<String?> getPlatformVersion() {
    return AudioMergePlatform.instance.getPlatformVersion();
  }
}
