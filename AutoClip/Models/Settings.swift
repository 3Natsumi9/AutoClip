//
//  Settings.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/23.
//

import Foundation

class Settings: ObservableObject {
    static let shared = Settings()
    private init() {}
    /// 切り抜いたシーンの前に何秒映像を含めるか
    @Published var timeBeforeClip: SecondsKind = .three
    /// 切り抜いたシーンの後に何秒映像を含めるか
    @Published var timeAfterClip: SecondsKind = .three
    /// クリップ検出処理をする時間の間隔
    /// three, five, ten, fifteenしか選べない
    @Published var matchingProcessInterval: SecondsKind = .three
}
