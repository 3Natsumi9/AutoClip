//
//  VideoSeekManager.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/18.
//

import Foundation
import AVKit

struct VideoSeekManager {
    // seekTimesを取得する
    // [[←ボタンを押した時に、seekするCMTime, →ボタンを押した時に、seekするCMTime], ...]
    func getSeekTimes(detectedClipRanges: [CMTimeRange], videoTime: CMTime) -> [CMTimeRange] {
        /// 非クリップ検出範囲
        var nondetectedClipRanges: [CMTimeRange] = []
        /// 矢印ボタンを押した時に、seekさせる時間を管理する配列
        var seekTimes: [CMTimeRange] = []
        
        // 動画開始から最初のクリップ検出位置までの範囲
        seekTimes.append(.init(
            start: .zero, end: detectedClipRanges.first!.start
        ))
        
        // 非クリップ検出範囲を、配列に入れる
        for i in 0..<detectedClipRanges.count - 1 {
            nondetectedClipRanges.append(.init(
                start: detectedClipRanges[i].end, end: detectedClipRanges[i + 1].start
            ))
        }
        
        // クリップ検出範囲と非クリップ検出範囲は交互に繰り返されるので、
        // 最初はクリップ検出範囲をseekTimesに追加し、次は非クリップ範囲をseekTimesに追加する
        // これを必要な分だけ繰り返す
        for i in 0..<detectedClipRanges.count + nondetectedClipRanges.count {
            if i % 2 == 0 {
                seekTimes.append(detectedClipRanges[i / 2])
            } else {
                seekTimes.append(nondetectedClipRanges[i / 2])
            }
        }
        
        // 最後のクリップ検出範囲の終わりの位置から動画の終わりの位置までの範囲
        seekTimes.append(.init(
            start: detectedClipRanges.last!.end, end: .init(value: videoTime.value - 1, timescale: videoTime.timescale)
        ))
        
        return seekTimes
    }

    // clipRangeIndexを取得する
    // つまみがどこの間にあるのかを調べる
    func getClipRangesIndex(playTime: CMTime, seekTimes: [CMTimeRange]) -> Int {
        var index = 0
        for (i, timeRange) in seekTimes.enumerated() {
            index = i

            if i % 2 == 0 {
                if !(playTime.value > timeRange.start.value && playTime.value < timeRange.end.value) {
                    continue
                }
            } else {
                if !(playTime.value >= timeRange.start.value && playTime.value <= timeRange.end.value) {
                    continue
                }
            }
            
            break
        }
        return index
    }
}
