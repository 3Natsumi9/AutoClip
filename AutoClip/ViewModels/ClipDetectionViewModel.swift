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
    let item: AVPlayerItem
    var player: AVPlayer
    @Published var progress: Float = 0.0
    @Published var gameSelection: GameKind = .apex
    @Published var gameSceneSelection: GameSceneKind = .kill
    /// クリップ検出処理中か
    @Published var isProgress = false
    /// 処理が終了したか
    @Published var isProcessFinished = false
    var detectedClipRanges: [CMTimeRange] = []
    var cancellable: AnyCancellable?
    
    init(videoUrl: URL) {
        self.videoUrl = videoUrl
        self.item = AVPlayerItem(url: videoUrl)
        self.player = AVPlayer(playerItem: item)
    }
    
    func createClipDetectionProcess(settings: Settings) {
        self.model = .init(game: self.gameSelection, matchSeconds: settings.matchingProcessInterval, videoUrl: self.videoUrl)
        
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
                    self.isProcessFinished = true
            })
        }
    }
}

