//
//  ClipEditingViewModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/18.
//

import SwiftUI
import AVKit
import Combine

class ClipEditingViewModel: ObservableObject {
    // FIXME: detectedClipRangesを実際のデータから渡す
    @Published var model = VideoPlayerManager.setup(detectedClipRanges: [
        .init(start: CMTimeMakeWithSeconds(10, preferredTimescale: 15360), end: CMTimeMakeWithSeconds(100, preferredTimescale: 15360)),
        .init(start: CMTimeMakeWithSeconds(200, preferredTimescale: 15360), end: CMTimeMakeWithSeconds(300, preferredTimescale: 15360)),
        .init(start: CMTimeMakeWithSeconds(330, preferredTimescale: 15360), end: CMTimeMakeWithSeconds(370, preferredTimescale: 15360)),
        .init(start: CMTimeMakeWithSeconds(400, preferredTimescale: 15360), end: CMTimeMakeWithSeconds(500, preferredTimescale: 15360)),
        .init(start: CMTimeMakeWithSeconds(550, preferredTimescale: 15360), end: CMTimeMakeWithSeconds(660, preferredTimescale: 15360)),
    ])
    @Published var playTime: CMTime = .zero
    @Published var videoTime: CMTime = .zero
    @Published var seekTimes: [CMTimeRange] = []
    @Published var videoItems: [VideoItem] = []
    @Published var clipRangesIndex = 0
    @Published var videoItemsIndex = 0
    @Published var isPlayable = false
    
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
    
    func seekBarChanged(cmTime: CMTime) {
        seekBarPublisher(cmTime: cmTime)
    }
    
    var seekBarPublisherCancellable: AnyCancellable?
    var videoTimeSubjectCancellable: AnyCancellable?
    var playTimeSubjectCancellable: AnyCancellable?
    
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
    
    init() {
         let manager = VideoSeekManager()
    
        cancellables = [
            seekBarPublisherCancellable, videoTimeSubjectCancellable, playTimeSubjectCancellable
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
            .sink { cmTime in
                print("changed")
                self.playTime = cmTime
            }
    }
    
    deinit {
        print("deinit")
        cancellables.forEach {
            if let cancellable = $0 {
                cancellable.cancel()
            }
        }
    }
}
