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
            //ContentView()
            ProjectView(projectName: "movie01", gameName: "Apex Legends", image: Image("test"), movieTime: "40:00", clips: 10)
        }
    }
}
