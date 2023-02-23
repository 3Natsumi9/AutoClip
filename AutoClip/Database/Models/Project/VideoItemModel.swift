//
//  VideoItemModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/19.
//

import RealmSwift

class VideoItemModel: Object {
    /// 検出されたクリップの範囲
    @Persisted var detectedClipRange: TimeRange?
    /// クリップの前に映像を含める秒数
    @Persisted var timeBeforeClip: SecondsKind?
    /// クリップの後に映像を含める秒数
    @Persisted var timeAfterClip: SecondsKind?
    /// 動画時間
    @Persisted var videoTime: Time?
    /// 動画の範囲(クリップの前、後に映像を含めての範囲)
    @Persisted var range: TimeRange?
    /// 出力するかどうか
    @Persisted var isOutput = false
}
