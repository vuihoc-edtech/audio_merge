#import "AudioMergePlugin.h"
#if __has_include(<audio_merge/audio_merge-Swift.h>)
#import <audio_merge/audio_merge-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "audio_merge-Swift.h"
#endif

@implementation AudioMergePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioMergePlugin registerWithRegistrar:registrar];
}
@end
