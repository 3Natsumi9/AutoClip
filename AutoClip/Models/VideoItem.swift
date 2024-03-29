//
//  VideoItem.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/18.
//

import Foundation
import AVFoundation

class VideoItem {
    /// 検出されたクリップの範囲
    let detectedClipRange: CMTimeRange
    /// クリップの前に映像を含める秒数
    var timeBeforeClip: SecondsKind
    /// クリップの後に映像を含める秒数
    var timeAfterClip: SecondsKind
    /// 動画時間
    let videoTime: CMTime
    /// 動画の範囲(クリップの前、後に映像を含めての範囲)
    var range: CMTimeRange {
        get {
            var range = CMTimeRange()
            let start = detectedClipRange.start.seconds - Double(self.timeBeforeClip.value)
            let end = detectedClipRange.end.seconds + Double(self.timeAfterClip.value)
            var startCMTime: CMTime
            var endCMTime: CMTime
            if !(start < 0) {
                startCMTime = CMTime(seconds: start, preferredTimescale: self.videoTime.timescale)
            } else {
                startCMTime = CMTime(value: 0, timescale: self.videoTime.timescale)
            }
            if !(end > self.videoTime.seconds) {
                endCMTime = CMTime(seconds: end, preferredTimescale: self.videoTime.timescale)
            } else {
                endCMTime = self.videoTime
            }
            
            range = CMTimeRange(start: startCMTime, end: endCMTime)
            return range
        }
    }
    /// 出力するかどうか
    var isOutput = false
    
    init(clipRange detectedClipRange: CMTimeRange, before timeBeforeClip: SecondsKind, after timeAfterClip: SecondsKind, videoTime: CMTime) {
        self.detectedClipRange = detectedClipRange
        self.timeBeforeClip = timeBeforeClip
        self.timeAfterClip = timeAfterClip
        self.videoTime = videoTime
        
        print("detectedClipRange:", self.detectedClipRange.start.seconds, self.detectedClipRange.end.seconds)
        print("range:", self.range.start.seconds, self.range.end.seconds)
    }
}

extension Array where Element == VideoItem {
    func searchIndex(playTime: CMTime) -> Int {
        for (i, item) in self.enumerated() {
            if playTime.value >= item.range.start.value && playTime.value <= item.range.end.value {
                return i
            }
        }
        return -1
    }
    
    func dispInfo() {
        self.forEach {
            print($0)
        }
    }
}
