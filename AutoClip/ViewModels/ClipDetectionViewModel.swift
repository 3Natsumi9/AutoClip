//
//  ClipDetectionViewModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/13.
//

import SwiftUI
import AVFoundation
import Combine

class ClipDetectionViewModel: ObservableObject {
    @Published var model: ClipDetectionProcess?
    let videoUrl: URL
    let localIdentifier: String
    let item: AVPlayerItem
    var player: AVPlayer
    @Published var projectName = ""
    @Published var progress: Float = 0.0
    @Published var gameSelection: GameKind = .splatoon
    @Published var gameSceneSelection: GameSceneKind = .kill
    @Published var threshold: Float = 50.0
    /// クリップ検出処理中か
    @Published var isProgress = false
    /// 処理が終了したか
    @Published var isProcessFinished = false
    /// クリップが一つも検出されなかったか
    @Published var clipDetectionFailedIs = false
    var detectedClipRanges: [CMTimeRange] = []
    var cancellable: AnyCancellable?
    
    init(videoUrl: URL, localIdentifier: String) {
        self.videoUrl = videoUrl
        self.localIdentifier = localIdentifier
        self.item = AVPlayerItem(url: videoUrl)
        self.player = AVPlayer(playerItem: item)
        self.projectName = "ムービー\(String(format: "%02d", UserDefaults.standard.integer(forKey: "NumberOfProject") + 1))"
    }
    
    func createClipDetectionProcess(settings: Settings) {
        self.model = .init(game: self.gameSelection, scene: self.gameSceneSelection, threshold: self.threshold, matchSeconds: settings.matchingProcessInterval, videoUrl: self.videoUrl)
        
        self.model?.progressPublisherCancellable = self.model?.progressPublisher
            .sink(receiveValue: {
                self.progress = $0
                
                if $0 == 100.0 {
                    self.model?.progressPublisherCancellable?.cancel()
                }
            })
    }
    
    func startDetection() {
        if let model = model {
            cancellable = model.fetch()
                .sink(receiveValue: {
                    self.detectedClipRanges = $0
                    self.isProgress = false
                    
                    if $0.isEmpty {
                        self.clipDetectionFailedIs = true
                    } else {
                        self.isProcessFinished = true
                    }
            })
        }
    }
}

