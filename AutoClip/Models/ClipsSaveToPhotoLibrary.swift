//
//  ClipsSaveToPhotoLibrary.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/01.
//

import Foundation
import Combine
import AVFoundation
import Photos

class ClipsSaveToPhotoLibrary {
    var asset: AVAsset
    var videoTrack: AVAssetTrack?
    var resultPublisher = PassthroughSubject<Bool, Never>()
    var cancellable: AnyCancellable?
    
    init(asset: AVAsset) {
        self.asset = asset
    }
    
    func fetch(range: CMTimeRange) {
        let publisher = Publishers.CombineLatest(videoTrackPublisher(asset: asset), audioTrackPublisher(asset: asset))
            .tryMap { videoTrack, audioTrack -> AVMutableComposition in
                let composition = AVMutableComposition()
                
                let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
                
                try videoCompositionTrack.insertTimeRange(range, of: videoTrack, at: .zero)
                
                let audioCompositiontrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                
                try audioCompositiontrack.insertTimeRange(range, of: audioTrack, at: .zero)
                
                return composition
            }
            .map { composition -> AVAssetExportSession? in
                AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            }
            .eraseToAnyPublisher()
        
        publisher.sink(receiveCompletion: {_ in
            
        }, receiveValue: { exporter in
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString)clip.mov")
            try? FileManager.default.removeItem(at: outputURL)
            exporter?.outputURL = outputURL
            exporter?.outputFileType = .mov
            
            exporter?.exportAsynchronously {
                if exporter?.status == .completed {
                    print("出力が完了しました")
                    PHPhotoLibrary.requestAuthorization { status in
                        switch status {
                        case .authorized:
                            PHPhotoLibrary.shared().performChanges({
                                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)!
                                request.creationDate = Date()
                            }, completionHandler: { success, error in
                                if success {
                                    self.resultPublisher.send(true)
                                    print("フォトライブラリへの保存が完了しました")
                                } else {
                                    self.resultPublisher.send(false)
                                    print("エラー: \(error?.localizedDescription ?? "")")
                                }
                            })
                        case .denied, .restricted:
                            self.resultPublisher.send(false)
                            print("フォトライブラリへの権限がありません")
                        case .notDetermined:
                            self.resultPublisher.send(false)
                            print("notDetermined")
                        case .limited:
                            self.resultPublisher.send(false)
                            print("limited")
                        @unknown default:
                            self.resultPublisher.send(false)
                            print("不明なエラー")
                        }
                    }
                } else {
                    print("Export Failed: \(exporter?.error.debugDescription ?? "Unknown Error")")
                }
            }
        })
        .cancel()
    }
    
    private func videoTrackPublisher(asset: AVAsset) -> AnyPublisher<AVAssetTrack, Never> {
        Deferred {
            Future<AVAssetTrack, Never> { promiss in
                asset.loadTracks(withMediaType: .video) { tracks, _ in
                    promiss(.success(tracks!.first!))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func audioTrackPublisher(asset: AVAsset) -> AnyPublisher<AVAssetTrack, Never> {
        Deferred {
            Future<AVAssetTrack, Never> { promiss in
                asset.loadTracks(withMediaType: .audio) { tracks, _ in
                    promiss(.success(tracks!.first!))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
