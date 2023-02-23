//
//  ProjectModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/19.
//

import RealmSwift

class Project: Object {
    /// プロジェクト名
    @Persisted var name = ""
    /// ゲーム
    @Persisted var game: GameKind?
    /// 検出されたクリップの数
    @Persisted var clips = 0
    /// 動画時間(秒)
    @Persisted var videoSeconds: Float64 = 0.0
    /// フォトライブラリの動画を取得するための識別子
    @Persisted var localIdentifier = ""
    /// videoItem
    @Persisted var videoItems = List<VideoItemModel>()
    
    override class func primaryKey() -> String? {
        "name"
    }
}
