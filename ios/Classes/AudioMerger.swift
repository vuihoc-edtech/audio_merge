//
//  AudioMerger.swift
//  audio_merge
//
//  Created by manhpd on 21/02/2024.
//

import Foundation
import AVFoundation

protocol AudioMergerProtocal {
    func mergeAudios(audios: [AudioModel],
                     completion: @escaping (_ mergedVideoURL: URL?, _ error: Error?) -> Void)
}

@objc open class AudioMerger: NSObject {

}

// MARK:-  Public Functions
extension AudioMerger: AudioMergerProtocal {

    static var exporter: AVAssetExportSession?
    
    func mergeAudios(audios: [AudioModel], completion: @escaping (URL?, Error?) -> Void) {
        let composition = AVMutableComposition()
        
        for i in 0 ..< audios.count {
            
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
            
            let url = URL(fileURLWithPath: audios[i].pathAudio)
            
            let asset = AVURLAsset(url: url)
            
            let track = asset.tracks(withMediaType: AVMediaType.audio)[0]
            
            if (i == 0) {
                let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600),
                                            duration: track.timeRange.duration)
                try! compositionAudioTrack?.insertTimeRange(timeRange, of: track, at: composition.duration)
            } else {
                let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600),
                                            duration: track.timeRange.duration)
                
                let duration = CMTime(seconds: Double(i * 3), preferredTimescale: 1)
                
                
                try! compositionAudioTrack?.insertTimeRange(timeRange, of: track, at:
                                                                duration)
            }
        }
        
        
        
        AudioMerger.exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        AudioMerger.exporter?.outputFileType = AVFileType.m4a
        AudioMerger.exporter?.outputURL = URL.documents.appendingPathComponent("FinalAudio5.m4a")
        
        let exportCompletion: (() -> Void) = {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                completion(AudioMerger.exporter?.outputURL, AudioMerger.exporter?.error)
            })
        }
        if let exportSession = AudioMerger.exporter {
            exportSession.exportAsynchronously(completionHandler: {() -> Void in
                switch exportSession.status {
                case .completed:
                    debugPrint("Successfully merged: %@", exportSession.outputURL ?? "")
                    exportCompletion()
                case .failed:
                    debugPrint("Failed %@",exportSession.error ?? "")
                    exportCompletion()
                case .cancelled:
                    debugPrint("Cancelled")
                    exportCompletion()
                case .unknown:
                    debugPrint("Unknown")
                case .exporting:
                    debugPrint("Exporting")
                case .waiting:
                    debugPrint("Wating")
                @unknown default:
                    debugPrint("default")
                }
            })
        }
    }
    
}
