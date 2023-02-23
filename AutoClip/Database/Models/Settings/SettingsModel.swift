//
//  SettingsModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/19.
//

import Foundation
import RealmSwift

class SettingsModel: Object {
    /// 切り抜いたシーンの前に何秒映像を含めるか
    @Persisted var timeBeforeClip: SecondsKind?
    /// 切り抜いたシーンの後に何秒映像を含めるか
    @Persisted var timeAfterClip: SecondsKind?
    /// クリップ検出処理をする時間の間隔
    @Persisted var matchingProcessInterval: SecondsKind?
}
