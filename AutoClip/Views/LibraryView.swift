//
//  LibraryView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/07.
//

import SwiftUI

struct LibraryView: View {
    @State var videoUrl: URL?
    @State var isShowPickerView = false
    @State var isShowClipDetectionView = false
    @State var isLoading = false
    var body: some View {
        ZStack {
            NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            ProjectView(projectName: "test", gameName: "hoge", image: Image("test"), movieTime: "30:00", clips: 3)
                            ProjectView(projectName: "test", gameName: "hoge", image: Image("test"), movieTime: "30:00", clips: 3)
                        }
                        .navigationTitle("ライブラリ")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    isShowPickerView.toggle()
                                } label: {
                                    Text("追加")
                                }
                            }
                        }
                        .sheet(isPresented: $isShowPickerView) {
                            PhotoLibraryVideoPickerView(videoUrl: $videoUrl, isLoading: $isLoading)
                        }
                        .onChange(of: videoUrl) { url in
                            if let _ = url {
                                isShowClipDetectionView = true
                            }
                        }
                        
                        NavigationLink(destination: ClipDetectionView(vm: ClipDetectionViewModel(videoUrl: videoUrl!)).environmentObject(Settings.shared), isActive: $isShowClipDetectionView) {
                            EmptyView()
                        }
                    }
                    
            }
            if isLoading {
                Color.gray
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.5)
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
