//
//  ClipItemViewModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/30.
//

import UIKit
import AVFoundation

class ClipItemViewModel: ObservableObject {
    let title: String
    @Published var videoItem: VideoItem
    @Published var thumbnailImage: UIImage
    @Published var isOutput = false
    
    init(title: String, videoItem: VideoItem, avAsset asset: AVAsset) {
        self.title = title
        self.videoItem = videoItem
        self.thumbnailImage = UIImage(systemName: "photo.fill")!
        
        let extractor = StillImageExtractor(asset: asset)
        
        self.thumbnailImage = extractor.generateImage(time: videoItem.range.start)
    }
}
