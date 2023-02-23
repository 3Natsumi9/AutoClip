//
//  ProjectViewModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/19.
//

import SwiftUI

class ProjectViewModel: ObservableObject, Identifiable {
    let id = UUID()
    let projectName: String
    let game: GameKind
    let image: Image
    let videoSeconds: Float64
    let clips: Int
    
    init(projectName: String, game: GameKind, image: Image, videoSeconds: Float64, clips: Int) {
        self.projectName = projectName
        self.game = game
        self.image = image
        self.videoSeconds = videoSeconds
        self.clips = clips
    }
}
