//
//  ClipEditingViewModel.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/18.
//

import SwiftUI
import AVFoundation
import Combine
import RealmSwift

class ClipEditingViewModel: ObservableObject {
    let projectName: String
    let localIdentifier: String
    let game: GameKind
    var videoLoadedFromDB: Bool
    @Published var model: VideoPlayerManager
    @Published var playTime: CMTime = .zero
    @Published var videoTime: CMTime = .zero
    @Published var seekTimes: [CMTimeRange] = []
    @Published var videoItems: [VideoItem] = []
    @Published var clipRangesIndex = 0
    @Published var videoItemsIndex = 0
    @Published var isPlayable = false
    @Published var isPlay = false
    @Published var isSaving = false
    @Published var isSaveFinished = false
    
    // データベース処理の完了を通知する
    var dbPublisher = PassthroughSubject<Void, Never>()
    
    
    
    var detectedClipRanges: [CMTimeRange] {
        model.detectedClipRanges
    }
    
    var outputClips: [VideoItem] {
        get {
            model.outputClips
        }
        set {
            model.outputClips = newValue
        }
    }
    
    var player: AVPlayer {
        model.player
    }
    
    var asset: AVAsset {
        model.asset
    }
    
    var playerItem: AVPlayerItem {
        model.playerItem
    }
    
    private var videoTimeSubject: PassthroughSubject<CMTime, Never> {
        get {
            model.videoTimeSubject
        }
        set {
            model.videoTimeSubject = newValue
        }
    }
    
    private var playTimeSubject: PassthroughSubject<CMTime, Never> {
        get {
            model.playTimeSubject
        }
        set {
            model.playTimeSubject = newValue
        }
    }
    
    private var isPlaySubject: PassthroughSubject<Bool, Never> {
        get {
            model.isPlaySubject
        }
        set {
            model.isPlaySubject = newValue
        }
    }
    
    func seekBarChanged(cmTime: CMTime) {
        seekBarPublisher(cmTime: cmTime)
    }
    
    func saveProjectToDB() {
        if videoLoadedFromDB {
            updateProject()
        } else {
            saveNewProject()
        }
    }
    
    private func updateProject() {
        isSaving = true
        let realm = try! Realm()
        let project = realm.objects(Project.self).where({ $0.name == projectName }).first!
        
        let tmp = RealmSwift.List<VideoItemModel>()
        
        self.videoItems.forEach { item in
            let videoItemModel = VideoItemModel()

            let detectedClipRange = TimeRange()
            detectedClipRange.start = { () -> Time in
                let time = Time()
                time.value = Int(item.detectedClipRange.start.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            detectedClipRange.end = { () -> Time in
                let time = Time()
                time.value = Int(item.detectedClipRange.end.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            videoItemModel.detectedClipRange = detectedClipRange
            
            videoItemModel.timeBeforeClip = item.timeBeforeClip
            videoItemModel.timeAfterClip = item.timeAfterClip
            videoItemModel.videoTime = { () -> Time in
                let time = Time()
                time.value = Int(item.videoTime.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            let range = TimeRange()
            range.start = { () -> Time in
                let time = Time()
                time.value = Int(item.range.start.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            range.end = { () -> Time in
                let time = Time()
                time.value = Int(item.range.end.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            videoItemModel.range = range
            
            videoItemModel.isOutput = item.isOutput
            
            tmp.append(videoItemModel)
        }
        
        try! realm.write {
            project.videoItems = tmp
        }
        
        isSaving = false
        isSaveFinished = true
        print("更新完了")
    }
    
    private func saveNewProject() {
        isSaving = true
        let project = Project()
        
        project.name = projectName
        project.game = game
        project.clips = detectedClipRanges.count
        project.videoSeconds = CMTimeGetSeconds(videoTime)
        project.localIdentifier = localIdentifier
        
        self.videoItems.forEach { item in
            let videoItemModel = VideoItemModel()

            let detectedClipRange = TimeRange()
            detectedClipRange.start = { () -> Time in
                let time = Time()
                time.value = Int(item.detectedClipRange.start.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            detectedClipRange.end = { () -> Time in
                let time = Time()
                time.value = Int(item.detectedClipRange.end.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            videoItemModel.detectedClipRange = detectedClipRange
            
            videoItemModel.timeBeforeClip = item.timeBeforeClip
            videoItemModel.timeAfterClip = item.timeAfterClip
            videoItemModel.videoTime = { () -> Time in
                let time = Time()
                time.value = Int(item.videoTime.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            let range = TimeRange()
            range.start = { () -> Time in
                let time = Time()
                time.value = Int(item.range.start.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            range.end = { () -> Time in
                let time = Time()
                time.value = Int(item.range.end.value)
                time.timescale = Int(item.videoTime.timescale)
                return time
            }()
            
            videoItemModel.range = range
            
            videoItemModel.isOutput = item.isOutput
            
            project.videoItems.append(videoItemModel)
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(project, update: .modified)
        }
        
        videoLoadedFromDB = true
        
        isSaving = false
        isSaveFinished = true
        print("保存完了")
    }
    
    var seekBarPublisherCancellable: AnyCancellable?
    var videoTimeSubjectCancellable: AnyCancellable?
    var playTimeSubjectCancellable: AnyCancellable?
    var isPlaySubjectCancellable: AnyCancellable?
    
    var cancellables: [AnyCancellable?]
    
    private func seekBarPublisher(cmTime: CMTime) {
        seekBarPublisherCancellable = Deferred {
            Future<CMTime, Never> { promiss in
                promiss(.success(cmTime))
            }
        }
        .eraseToAnyPublisher()
        .sink { cmTime in
            self.player.rate = 0.0
            self.player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
            self.player.rate = 1.0
        }
    }
    
    init(projectName: String, game: GameKind, videoLoadedFromDB: Bool, videoUrl: URL, localIdentifier: String, detectedClipRanges: [CMTimeRange]) {
        self.projectName = projectName
        self.game = game
        self.videoLoadedFromDB = videoLoadedFromDB
        self.localIdentifier = localIdentifier
        
        self.model = VideoPlayerManager.setup(videoUrl: videoUrl, detectedClipRanges: detectedClipRanges)
        
        let manager = VideoSeekManager()
        
        cancellables = [
            seekBarPublisherCancellable, videoTimeSubjectCancellable, playTimeSubjectCancellable, isPlaySubjectCancellable
        ]
        
        videoTimeSubjectCancellable = videoTimeSubject
            .filter { cmTime in
                cmTime != .zero
            }
            .sink { cmTime in
                print("videoTime:", cmTime)
                self.videoTime = cmTime
                self.seekTimes = manager.getSeekTimes(detectedClipRanges: self.detectedClipRanges, videoTime: self.videoTime)
                self.videoTimeSubjectCancellable?.cancel()
                
                for detectedClipRange in self.detectedClipRanges {
                    self.videoItems.append(
                        .init(clipRange: detectedClipRange, before: Settings.shared.timeBeforeClip, after: Settings.shared.timeAfterClip, videoTime: self.videoTime)
                    )
                }
                
                self.isPlayable = true
                self.player.play()
            }
        
        playTimeSubjectCancellable = playTimeSubject
            .dropFirst()
            .sink {
                self.playTime = $0
            }
        
        isPlaySubjectCancellable = isPlaySubject
            .sink { isPlay in
                DispatchQueue.main.async {
                    self.isPlay = isPlay
                }
            }
    }
    
    init(projectName: String, game: GameKind, videoLoadedFromDB: Bool, videoUrl: URL, localIdentifier: String, videoItems: [VideoItem]) {
        self.projectName = projectName
        self.game = game
        self.videoLoadedFromDB = videoLoadedFromDB
        self.localIdentifier = localIdentifier
        self.videoItems = videoItems
        
        let detectedClipRanges = videoItems.map { $0.detectedClipRange }
        
        self.model = VideoPlayerManager.setup(videoUrl: videoUrl, detectedClipRanges: detectedClipRanges)
        
        let manager = VideoSeekManager()
        
        cancellables = [
            seekBarPublisherCancellable, videoTimeSubjectCancellable, playTimeSubjectCancellable, isPlaySubjectCancellable
        ]
        
        videoTimeSubjectCancellable = videoTimeSubject
            .filter { cmTime in
                cmTime != .zero
            }
            .sink { cmTime in
                print("videoTime:", cmTime)
                self.videoTime = cmTime
                self.seekTimes = manager.getSeekTimes(detectedClipRanges: self.detectedClipRanges, videoTime: self.videoTime)
                self.videoTimeSubjectCancellable?.cancel()
                
                self.isPlayable = true
                self.player.play()
            }
        
        playTimeSubjectCancellable = playTimeSubject
            .dropFirst()
            .sink {
                self.playTime = $0
            }
        
        isPlaySubjectCancellable = isPlaySubject
            .sink { result in
                DispatchQueue.main.async {
                    self.isPlay = result
                }
            }
    }
    
    deinit {
        cancellables.forEach {
            if let cancellable = $0 {
                cancellable.cancel()
            }
        }
    }
}
