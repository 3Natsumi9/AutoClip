//
//  AutoClipApp.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/07.
//

import SwiftUI

@main
struct AutoClipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Settings.shared)
        }
    }
}
