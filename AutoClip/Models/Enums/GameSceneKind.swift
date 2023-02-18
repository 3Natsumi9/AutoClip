//
//  GameSceneKind.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/13.
//

import Foundation

enum GameSceneKind: CaseIterable {    
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
