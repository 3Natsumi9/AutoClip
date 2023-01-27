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
    
    @Published var timeBeforeClip: SecondsKind = .three
    @Published var timeAfterClip: SecondsKind = .three
}
