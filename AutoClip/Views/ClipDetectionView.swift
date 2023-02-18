//
//  ClipDetectionView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/09.
//

import SwiftUI
import AVKit

struct ClipDetectionView: View {
    @StateObject var vm: ClipDetectionViewModel
    @EnvironmentObject var settings: Settings
    let sc = UIScreen.main.bounds
        
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15.0) {
                // VideoPlayerのサイズを16:9にする
                // frame指定しないと、縦幅が余分に取られてしまう
                VideoPlayer(player: vm.player)
                    .frame(width: sc.width, height: CGFloat((sc.width * 9) / 16))
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("対象のゲーム")
                                .font(.system(size: 16))
                            NavigationLink(
                                destination: gameSettingView(selection: $vm.gameSelection)
                            ) {
                                ButtonView("\(vm.gameSelection.name)")
                            }
                        }
                        VStack {
                            Text("切り抜くシーン")
                                .font(.system(size: 16))
                            NavigationLink(
                                destination: gameSceneSettingView(selection: $vm.gameSceneSelection)
                            ) {
                                ButtonView("\(vm.gameSceneSelection.name)")
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 7) {
                            Text("前後に映像を含める")
                                .font(.system(size: 16))
                            Text("切り抜いたシーンの前後に何秒映像を含めるかを指定できます。")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            HStack(spacing: 5) {
                                HStack {
                                    Text("前")
                                    NavigationLink(
                                        destination: timeSettingView(title:  "クリップの前に映像を含める秒数", selection: $settings.timeBeforeClip)
                                    ) {
                                        ButtonView("\(settings.timeBeforeClip.name)")
                                    }
                                }
                                HStack {
                                    Text("後")
                                    NavigationLink(
                                        destination: timeSettingView(title: "クリップの後に映像を含める秒数", selection: $settings.timeAfterClip)
                                    ) {
                                        ButtonView("\(settings.timeAfterClip.name)")
                                    }
                                }
                                .padding(.leading, 20.0)
                            }
                            
                            
                            
                        }
                        VStack(alignment: .leading, spacing: 7) {
                            Text("マッチング処理を行う間隔")
                                .font(.system(size: 16))
                            Text("間隔を狭くすればするほど正確なクリップ検出ができますが、処理時間が長くなります。")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            NavigationLink(
                                destination: timeSettingView(title: "マッチング処理を行う間隔", selection: $settings.matchingProcessInterval, ignoreTimes: [.zero, .twenty, .twentyfive, .thirty, .fourty, .fifty, .sixty])
                            ) {
                                ButtonView("\(settings.matchingProcessInterval.name)")
                            }
                        }
                        Spacer()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 15.0)
                    .navigationTitle("クリップ検出")
                    .navigationBarTitleDisplayMode(.inline)
                }
                HStack {
                    Spacer()
                    Button {
                        vm.isProgress = true
                        vm.createClipDetectionProcess(settings: settings)
                        vm.startDetection()
                    } label: {
                        ButtonView("検出開始！", color: .red, selectable: false, bold: true)
                    }
                    Spacer()
                }
                Spacer()
            }
            if vm.isProgress {
                Color.clear
                ClipDetectionProcessProgressView(progress: $vm.progress)
            }
            NavigationLink(destination: ClipEditingView(vm: ClipEditingViewModel(videoUrl: vm.videoUrl, detectedClipRanges: vm.detectedClipRanges)), isActive: $vm.isProcessFinished) {
                EmptyView()
            }
        }
            .onAppear {
                // 「対象のゲーム」などを選択するために、別Viewに遷移したときにonDisappearが走ってしまい、CurrentItemがnilになってしまうので
                // このViewに戻ってきたときに再度playerにplayerItemを指定する
                vm.player.replaceCurrentItem(with: vm.item)
            }
            .onDisappear {
                // libraryViewに戻ったときに、動画が裏で再生され続けてしまうのでCurrentItemをnilにする
                vm.player.replaceCurrentItem(with: nil)
            }
    }
}
