//
//  ClipEditingViewModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/18.
//

import SwiftUI
import AVFoundation
import Combine

class ClipEditingViewModel: ObservableObject {
    @Published var model: VideoPlayerManager
    @Published var playTime: CMTime = .zero
    @Published var videoTime: CMTime = .zero
    @Published var seekTimes: [CMTimeRange] = []
    @Published var videoItems: [VideoItem] = []
    @Published var clipRangesIndex = 0
    @Published var videoItemsIndex = 0
    @Published var isPlayable = false
    @Published var isPlay = false
    
    var detectedClipRanges: [CMTimeRange] {
        model.detectedClipRanges
    }
    
    var outputClips: [VideoItem] {
        get {
            model.outputClips
        }
        set {
            model.outputClips = newValue
        }
    }
    
    var player: AVPlayer {
        model.player
    }
    
    var asset: AVAsset {
        model.asset
    }
    
    var playerItem: AVPlayerItem {
        model.playerItem
    }
    
    private var videoTimeSubject: PassthroughSubject<CMTime, Never> {
        get {
            model.videoTimeSubject
        }
        set {
            model.videoTimeSubject = newValue
        }
    }
    
    private var playTimeSubject: PassthroughSubject<CMTime, Never> {
        get {
            model.playTimeSubject
        }
        set {
            model.playTimeSubject = newValue
        }
    }
    
    private var isPlaySubject: PassthroughSubject<Bool, Never> {
        get {
            model.isPlaySubject
        }
        set {
            model.isPlaySubject = newValue
        }
    }
    
    func seekBarChanged(cmTime: CMTime) {
        seekBarPublisher(cmTime: cmTime)
    }
    
    var seekBarPublisherCancellable: AnyCancellable?
    var videoTimeSubjectCancellable: AnyCancellable?
    var playTimeSubjectCancellable: AnyCancellable?
    var isPlaySubjectCancellable: AnyCancellable?
    
    var cancellables: [AnyCancellable?]
    
    private func seekBarPublisher(cmTime: CMTime) {
        seekBarPublisherCancellable = Deferred {
            Future<CMTime, Never> { promiss in
                promiss(.success(cmTime))
            }
        }
        .eraseToAnyPublisher()
        .sink { cmTime in
            self.player.rate = 0.0
            self.player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
            self.player.rate = 1.0
        }
    }
    
    init(videoUrl: URL, detectedClipRanges: [CMTimeRange]) {
        self.model = VideoPlayerManager.setup(videoUrl: videoUrl, detectedClipRanges: detectedClipRanges)
        
         let manager = VideoSeekManager()
        
        cancellables = [
            seekBarPublisherCancellable, videoTimeSubjectCancellable, playTimeSubjectCancellable, isPlaySubjectCancellable
        ]
        
        videoTimeSubjectCancellable = videoTimeSubject
            .filter { cmTime in
                cmTime != .zero
            }
            .sink { cmTime in
                print("videoTime:", cmTime)
                self.videoTime = cmTime
                self.seekTimes = manager.getSeekTimes(detectedClipRanges: self.detectedClipRanges, videoTime: self.videoTime)
                self.videoTimeSubjectCancellable?.cancel()
                
                for detectedClipRange in self.detectedClipRanges {
                    self.videoItems.append(
                        .init(clipRange: detectedClipRange, before: Settings.shared.timeBeforeClip, after: Settings.shared.timeAfterClip, videoTime: self.videoTime)
                    )
                }
                
                self.isPlayable = true
                self.player.play()
            }
        
        playTimeSubjectCancellable = playTimeSubject
            .dropFirst()
            .sink {
                self.playTime = $0
            }
        
        isPlaySubjectCancellable = isPlaySubject
            .sink {
                self.isPlay = $0
            }
    }
    
    deinit {
        cancellables.forEach {
            if let cancellable = $0 {
                cancellable.cancel()
            }
        }
    }
}
