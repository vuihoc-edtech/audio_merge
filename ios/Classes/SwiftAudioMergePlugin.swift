import Flutter
import UIKit
import AVFoundation
import MediaPlayer

typealias Codable = Decodable & Encodable

struct AudioModel: Codable {
    let index: Int
    let pathAudio: String

    private enum CodingKeys : String, CodingKey {
        case index = "index"
        case pathAudio = "path_audio"
    }
    
    init(index: Int, pathAudio: String) {
        self.index = index
        self.pathAudio = pathAudio
    }
}

enum AudioMergeType: String {
    case mergeAudio  = "MERGE_AUDIO"
}

public class SwiftAudioMergePlugin: NSObject, FlutterPlugin {
    static var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_merge",
                                           binaryMessenger: registrar.messenger())
        self.channel = channel
        let instance = SwiftAudioMergePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(call.method)
        switch(call.method) {
        case AudioMergeType.mergeAudio.rawValue:
            do {
                let arguments = call.arguments

                let jsonData = try JSONSerialization.data(withJSONObject: arguments ?? [:], options: [])
                let audios = try JSONDecoder().decode([FailableDecodable<AudioModel>].self, from: jsonData).compactMap { $0.base }
                AudioMerger().mergeAudios(audios: audios) { path, error in
                    SwiftAudioMergePlugin.notifyFlutter(event: EventType.AUDIO_MERGED, arguments: path)
                }
            } catch {
                print(error)
            }
            result("")
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    public static func notifyFlutter(event: EventType, arguments: Any?) {
        SwiftAudioMergePlugin.channel?.invokeMethod(event.rawValue, arguments: arguments)
    }
}

public enum EventType: String {
    case AUDIO_MERGED
}
