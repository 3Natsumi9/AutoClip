//
//  LibraryViewModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/19.
//

import SwiftUI
import RealmSwift
import AVFoundation
import Photos

class LibraryViewModel: ObservableObject {
    @Published var videoUrl: URL?
    @Published var localIdentifier = ""
    @Published var isShowPickerView = false
    @Published var isShowClipDetectionView = false
    @Published var isShowClipEditingView = false
    @Published var isLoading = false
    @Published var projectVMs: [ProjectViewModel] = []
    @Published var projects: [Project] = []
    
    init() {
        let realm = try! Realm()
        realm.objects(Project.self).forEach {
            var image = Image(systemName: "exclamationmark.circle")
            let localIdentifier = $0.localIdentifier
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            guard let asset = fetchResult.firstObject else {
                print("フォトライブラリに動画がありませんでした")
                return
            }
            
            let options = PHVideoRequestOptions()
            options.version = .original
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            
            let manager = PHImageManager.default()
            let imgOptions = PHImageRequestOptions()
            imgOptions.isSynchronous = true
            manager.requestImage(for: asset, targetSize: CGSize(width: 1280, height: 720), contentMode: .aspectFit, options: imgOptions) { uiImage, _ in
                if let uiImage = uiImage {
                    image = Image(uiImage: uiImage)
                }
            }
            
            let project = ProjectViewModel(projectName: $0.name, game: $0.game!, image: image, videoSeconds: $0.videoSeconds, clips: $0.clips)
            self.projectVMs.append(project)
            self.projects.append($0)
        }
    }
    
    func reload() {
        let realm = try! Realm()
        projectVMs.removeAll()
        projects.removeAll()
        realm.objects(Project.self).forEach {
            if $0.isInvalidated {
                return
            }
            var image = Image(systemName: "exclamationmark.circle")
            let localIdentifier = $0.localIdentifier
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            guard let asset = fetchResult.firstObject else {
                print("フォトライブラリに動画がありませんでした")
                return
            }
            
            let options = PHVideoRequestOptions()
            options.version = .original
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            
            let manager = PHImageManager.default()
            let imgOptions = PHImageRequestOptions()
            imgOptions.isSynchronous = true
            manager.requestImage(for: asset, targetSize: CGSize(width: 1280, height: 720), contentMode: .aspectFit, options: imgOptions) { uiImage, _ in
                if let uiImage = uiImage {
                    image = Image(uiImage: uiImage)
                }
            }
            
            let project = ProjectViewModel(projectName: $0.name, game: $0.game!, image: image, videoSeconds: $0.videoSeconds, clips: $0.clips)
            self.projectVMs.append(project)
            self.projects.append($0)
        }
    }
    
    func createVideoItem(project: Project) -> [VideoItem] {
        var videoItems: [VideoItem] = []
        project.videoItems.forEach({ item in
            let clipRange = CMTimeRange(start: .init(value: CMTimeValue(item.detectedClipRange!.start!.value), timescale: CMTimeScale(item.videoTime!.timescale)), end: .init(value: CMTimeValue(item.detectedClipRange!.end!.value), timescale: CMTimeScale(item.videoTime!.timescale)))
            let videoItem = VideoItem(clipRange: clipRange, before: item.timeBeforeClip!, after: item.timeAfterClip!, videoTime: CMTime(value: CMTimeValue(item.videoTime!.value), timescale: CMTimeScale(item.videoTime!.timescale)))
            
            videoItems.append(videoItem)
        })
        return videoItems
    }
    
    func removeDB(projectName: String) {
        let realm = try! Realm()
        let result = realm.objects(Project.self).where({ $0.name == projectName }).first!
        
        if !result.isInvalidated {
            try! realm.write {
                realm.delete(result)
            }
        }
    }
}
