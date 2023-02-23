//
//  SecondsKind.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/23.
//

import Foundation
import RealmSwift

enum SecondsKind: String, CaseIterable, RawRepresentable, PersistableEnum, Hashable {
    static var allCases: [SecondsKind] = [
        .zero, .three, .five, .ten, .fifteen, .twenty, .twentyfive, .thirty
    ]
    
    case zero
    case three
    case five
    case ten
    case fifteen
    case twenty
    case twentyfive
    case thirty
    case fourty
    case fifty
    case sixty
    
    var value: Int {
        switch self {
        case .zero:
            return 0
        case .three:
            return 3
        case .five:
            return 5
        case .ten:
            return 10
        case .fifteen:
            return 15
        case .twenty:
            return 20
        case .twentyfive:
            return 25
        case .thirty:
            return 30
        case .fourty:
            return 40
        case .fifty:
            return 50
        case .sixty:
            return 60
        }
    }
    
    var name: String {
        "\(value)秒"
    }
}
