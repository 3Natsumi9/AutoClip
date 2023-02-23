//
//  Settings.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/23.
//

import Foundation
import RealmSwift

class Settings: ObservableObject {
    static let shared = Settings()
    private init() {
        let realm = try! Realm()
        let settingsTable = realm.objects(SettingsModel.self)

        if settingsTable.isEmpty {
            createDB()
            return
        }

        if let settingsTable = settingsTable.first {
            self.timeBeforeClip = settingsTable.timeBeforeClip!
            self.timeAfterClip = settingsTable.timeAfterClip!
            self.matchingProcessInterval = settingsTable.matchingProcessInterval!
        } else {
            createDB()
        }
    }
    /// 切り抜いたシーンの前に何秒映像を含めるか
    @Published var timeBeforeClip: SecondsKind = .three
    /// 切り抜いたシーンの後に何秒映像を含めるか
    @Published var timeAfterClip: SecondsKind = .three
    /// クリップ検出処理をする時間の間隔
    /// three, five, ten, fifteenしか選べない
    @Published var matchingProcessInterval: SecondsKind = .three
    
    private func createDB() {
        let realm = try! Realm()
        
        let settingsModel = SettingsModel()
        settingsModel.timeBeforeClip = .three
        settingsModel.timeAfterClip = .three
        settingsModel.matchingProcessInterval = .three
        
        try! realm.write {
            realm.add(settingsModel)
        }
    }
}
