//
//  GameSceneKind.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/13.
//

import Foundation
import RealmSwift

enum GameSceneKind: String, CaseIterable, RawRepresentable, PersistableEnum {
    case kill
    case death
    
    var name: String {
        switch self {
        case .kill:
            return "キル"
        case .death:
            return "デス"
        }
    }
}
