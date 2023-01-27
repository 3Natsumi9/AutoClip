//
//  VideoPlayerManager.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/18.
//

import Foundation
import AVKit
import Combine

class VideoPlayerManager {
    /// 動画の再生位置
    var playTime: CMTime = .zero
    /// 検出されたクリップの範囲
    var detectedClipRanges: [CMTimeRange] = []
    /// 動画のシーク処理を行うときに、参照する動画時間
    var seekTimes: [CMTimeRange] = []
    /// シークバーのつまみの位置
    var clipRangesIndex: Int = 0
    /// 動画の長さ
    var videoTime: CMTime = .zero
    /// 検出されたクリップの範囲 + クリップ前後に含める動画の範囲
    /// そのクリップを出力するかどうかのパラメータ
    var outputClips: [VideoItem] = []
    
    let asset: NSDataAsset?
    let videoUrl: URL
    let playerItem: AVPlayerItem
    /// 動画を再生するプレイヤー
    let player: AVPlayer
    /// プレイヤーが動画を読み込んで、再生可能な状態か
    var isPlayable = false
    
    var playerStatusObserver: NSKeyValueObservation?
    var currentTimeObserver: Any?
    
    var playTimeSubject = PassthroughSubject<CMTime, Never>()
    var videoTimeSubject = PassthroughSubject<CMTime, Never>()
    var cancellable = Set<AnyCancellable>()
        
    init(detectedClipRanges: [CMTimeRange]) {
        self.detectedClipRanges = detectedClipRanges
        
        asset = NSDataAsset(name: "splatoon")
        videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("splatoon.mp4")

        try! asset!.data.write(to: videoUrl)
        playerItem = AVPlayerItem(url: videoUrl)
        player = AVPlayer(playerItem: playerItem)
        
        playerStatusObserver = player.observe(\.currentItem!.status) { data, status in
            switch data.status {
            case .unknown:
                break
            case .readyToPlay:
                print("readyToPlay")
                self.videoTime = data.currentItem!.duration
                self.videoTimeSubject.send(data.currentItem!.duration)
            case .failed:
                print("failed")
                break
            @unknown default:
                break
            }
        }
        
        currentTimeObserver = player.addPeriodicTimeObserver(forInterval: .init(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { cmTime in
            self.playTime = CMTime(seconds: cmTime.seconds, preferredTimescale: self.videoTime.timescale)
            self.playTimeSubject.send(self.playTime)
        }
    }
}
