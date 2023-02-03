//
//  StillImageExtractor.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/27.
//

import UIKit
import AVFoundation

class StillImageExtractor {
    let asset: AVAsset
    
    init(asset: AVAsset) {
        self.asset = asset
    }
    
    func generateImage(time: CMTime) -> UIImage {
        let generator = AVAssetImageGenerator(asset: asset)
        
        let capturedImage = try! generator.copyCGImage(at: time, actualTime: nil)
        
        return UIImage(cgImage: capturedImage)
    }
}
