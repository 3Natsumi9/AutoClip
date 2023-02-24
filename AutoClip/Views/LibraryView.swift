//
//  LibraryView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/07.
//

import SwiftUI
import AVFoundation
import Photos

struct LibraryView: View {
    @StateObject var vm: LibraryViewModel
    @State var positionX: [CGFloat]
    @State var startPositionX: [CGFloat]
    @State var isDragging: [Bool]
    @State var size: CGSize = .zero
    @State var isShowAlert: [Bool]
    
    init() {
        let model = LibraryViewModel()
        _vm = StateObject(wrappedValue: model)
        let vmCount = model.projectVMs.count
        
        _positionX = State(initialValue: Array(repeating: CGFloat(0.0), count: vmCount))
        _startPositionX = State(initialValue: Array(repeating: CGFloat(0.0), count: vmCount))
        _isDragging = State(initialValue: Array(repeating: false, count: vmCount))
        _isShowAlert = State(initialValue: Array(repeating: false, count: vmCount))
    }
    var body: some View {
        ZStack {
            ScrollView {
                GeometryReader { geo in
                    VStack(spacing: 20) {
                        ForEach(0..<vm.projects.count, id: \.self) { idx in
                            ProjectView(vm: vm.projectVMs[idx])
                                .offset(x: positionX[idx])
                                .animation(.default, value: positionX)
                                .gesture(
                                    DragGesture()
                                        .onChanged({ value in
                                            if !isDragging[idx] {
                                                startPositionX[idx] = positionX[idx]
                                                isDragging[idx] = true
                                            }
                                            if value.translation.width + startPositionX[idx] > -(geo.size.width / 4) && value.translation.width + startPositionX[idx] < 0 {
                                                positionX[idx] = value.translation.width + startPositionX[idx]
                                            }
                                        })
                                        .onEnded({ value in
                                            isDragging[idx] = false
                                            if value.translation.width + startPositionX[idx] > -(geo.size.width / 4.5) {
                                                positionX[idx] = 0.0
                                            }
                                            if value.translation.width + startPositionX[idx] < -(geo.size.width * 0.1) {
                                                positionX[idx] = -(geo.size.width / 4)
                                            }
                                        })
                                )
                                .onTapGesture {
                                    if positionX[idx] == -(geo.size.width / 4) {
                                        positionX[idx] = 0
                                    } else {
                                        vm.isLoading = true
                                        let localIdentifier = vm.projects[idx].localIdentifier
                                        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                                        guard let asset = fetchResult.firstObject else {
                                            vm.isLoading = false
                                            return
                                        }
                                        
                                        let options = PHVideoRequestOptions()
                                        options.version = .original
                                        options.deliveryMode = .highQualityFormat
                                        options.isNetworkAccessAllowed = true
                                        
                                        DispatchQueue.main.async {
                                            vm.localIdentifier = asset.localIdentifier
                                        }
                                        
                                        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                                            if let urlAsset = avAsset as? AVURLAsset {
                                                let fileName = "\(UUID().uuidString).\(urlAsset.url.pathExtension)"
                                                let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                                                try? FileManager.default.copyItem(at: urlAsset.url, to: newUrl)
                                                DispatchQueue.main.async {
                                                    vm.videoUrl = newUrl
                                                    print("url:", newUrl)
                                                    vm.isLoading = false
                                                    vm.isShowClipEditingView = true
                                                }
                                            } else {
                                                print("フォトライブラリに動画がありませんでした")
                                            }
                                        }
                                    }
                                }
                                .background(
                                    Color.red
                                        .cornerRadius(15.0)
                                        .overlay(
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: geo.size.width / 4)
                                                .overlay(
                                                    Text("削除")
                                                        .bold()
                                                        .foregroundColor(.white)
                                                )
                                            , alignment: .trailing
                                        )
                                        .onTapGesture {
                                            isShowAlert[idx] = true
                                        }
                                )
                                .alert("注意", isPresented: $isShowAlert[idx]) {
                                    Button("OK") {
                                        vm.removeDB(projectName: vm.projects[idx].name)
                                        vm.reload()
                                    }
                                    Button("Cancel") {}
                                } message: {
                                    Text("\(vm.projects[idx].name)を削除しますか？")
                                }
                                .fullScreenCover(isPresented: $vm.isShowClipEditingView) {
                                    NavigationView {
                                        ClipEditingView(vm: ClipEditingViewModel(
                                            projectName: vm.projects[idx].name,
                                            game: vm.projects[idx].game!,
                                            videoLoadedFromDB: true,
                                            videoUrl: vm.videoUrl!,
                                            localIdentifier: vm.localIdentifier,
                                            videoItems: vm.createVideoItem(project: vm.projects[idx])))
                                        .onDisappear {
                                            // ライブラリ画面を表示したときに、tempフォルダの中身を削除する
                                            let fileManager = FileManager.default
                                            let tmpDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                                            
                                            if let directoryContents = try? fileManager.contentsOfDirectory(at: tmpDirectoryURL, includingPropertiesForKeys: nil, options: []) {
                                                for fileURL in directoryContents {
                                                    do {
                                                        try fileManager.removeItem(at: fileURL)
                                                        print("テンポラリーフォルダを削除しました")
                                                    } catch {
                                                        print("テンポラリーフォルダの削除に失敗: \(error)")
                                                    }
                                                }
                                            }
                                            
                                            // プロジェクトを作成して、ライブラリ画面に戻ってきたときに表示されるようにリロードする
                                            vm.reload()
                                            
                                            let vmCount = vm.projectVMs.count
                                            
                                            self.positionX = Array(repeating: CGFloat(0.0), count: vmCount)
                                            self.startPositionX = Array(repeating: CGFloat(0.0), count: vmCount)
                                            self.isDragging = Array(repeating: false, count: vmCount)
                                            self.isShowAlert = Array(repeating: false, count: vmCount)
                                        }

                                    }
                                }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(minHeight: 1000)
                .navigationTitle("ライブラリ")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            vm.isShowPickerView.toggle()
                        } label: {
                            Text("追加")
                        }
                    }
                }
                .sheet(isPresented: $vm.isShowPickerView) {
                    PhotoLibraryVideoPickerView(videoUrl: $vm.videoUrl, localIdentifier: $vm.localIdentifier
                                                , isLoading: $vm.isLoading, isShowClipDetectionView: $vm.isShowClipDetectionView)
                }
                .fullScreenCover(isPresented: $vm.isShowClipDetectionView) {
                    ClipDetectionView(vm: ClipDetectionViewModel(videoUrl: vm.videoUrl!, localIdentifier: vm.localIdentifier))
                        .environmentObject(Settings.shared)
                        .onDisappear {
                            // ライブラリ画面を表示したときに、tempフォルダの中身を削除する
                            let fileManager = FileManager.default
                            let tmpDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                            
                            if let directoryContents = try? fileManager.contentsOfDirectory(at: tmpDirectoryURL, includingPropertiesForKeys: nil, options: []) {
                                for fileURL in directoryContents {
                                    do {
                                        try fileManager.removeItem(at: fileURL)
                                        print("テンポラリーフォルダを削除しました")
                                    } catch {
                                        print("テンポラリーフォルダの削除に失敗: \(error)")
                                    }
                                }
                            }
                            
                            // プロジェクトを作成して、ライブラリ画面に戻ってきたときに表示されるようにリロードする
                            vm.reload()
                            
                            let vmCount = vm.projectVMs.count
                            
                            self.positionX = Array(repeating: CGFloat(0.0), count: vmCount)
                            self.startPositionX = Array(repeating: CGFloat(0.0), count: vmCount)
                            self.isDragging = Array(repeating: false, count: vmCount)
                            self.isShowAlert = Array(repeating: false, count: vmCount)
                        }
                }
            }
            
            if vm.isLoading {
                Color.gray
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.51)
                ProgressView()
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
