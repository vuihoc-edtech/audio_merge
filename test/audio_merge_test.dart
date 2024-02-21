import 'package:audio_merge/audio_merge.dart';
import 'package:audio_merge/audio_merge_method_channel.dart';
import 'package:audio_merge/audio_merge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// class MockAudioMergePlatform
//     with MockPlatformInterfaceMixin
//     implements AudioMergePlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

void main() {
  final AudioMergePlatform initialPlatform = AudioMergePlatform.instance;

  test('$MethodChannelAudioMerge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioMerge>());
  });

  test('getPlatformVersion', () async {
    AudioMerge audioMergePlugin = AudioMerge();
    // MockAudioMergePlatform fakePlatform = MockAudioMergePlatform();
    // AudioMergePlatform.instance = fakePlatform;

    expect(await audioMergePlugin.getPlatformVersion(), '42');
  });
}
