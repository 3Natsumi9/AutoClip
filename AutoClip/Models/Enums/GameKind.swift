//
//  GameKind.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/10.
//

import Foundation

enum GameKind: CaseIterable {    
    case splatoon
    case apex
    case valorant
    
    var name: String {
        switch self {
        case .splatoon:
            return "スプラトゥーン"
        case .apex:
            return "Apex Legends"
        case .valorant:
            return "VALORANT"
        }
    }
}
