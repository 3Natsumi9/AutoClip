//
//  GameKind.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/10.
//

import Foundation
import RealmSwift

enum GameKind: String, CaseIterable, RawRepresentable, PersistableEnum {
    case splatoon
    
    var name: String {
        switch self {
        case .splatoon:
            return "スプラトゥーン"
        }
    }
    
    var killTemplateImageName: String {
        switch self {
        case .splatoon:
            return "splatoon_kill"
        }
    }
    
    var killMaskImageName: String {
        switch self {
        case .splatoon:
            return "splatoon_kill_mask"
        }
    }
    
    var deathTemplateImageName: String {
        switch self {
        case .splatoon:
            return "splatoon_death"
        }
    }
    
    var deathMaskImageName: String {
        switch self {
        case .splatoon:
            return "splatoon_death_mask"
        }
    }
        
}
