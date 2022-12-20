//
//  VideoPlayerController.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/12.
//

import SwiftUI
import AVKit

struct VideoPlayerController: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiView: AVPlayerViewController, context: Context) {
        
    }
}
