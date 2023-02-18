//
//  ClipEditingView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/27.
//

import SwiftUI
import AVKit

struct ClipEditingView: View {
    @StateObject var vm: ClipEditingViewModel
    
    let sc = UIScreen.main.bounds
    
    var body: some View {
        VStack {
            if !vm.isPlayable {
                ProgressView()
            } else {
                VStack {
                    // 16:9にする
                    VideoPlayerController(player: vm.player)
                        .frame(width: sc.width, height: CGFloat((sc.width * 9) / 16))
                    VStack(spacing: 35) {
                        SeekBarView(viewModel: vm)
                        HStack(spacing: 5) {
                            let _ = print("index", vm.videoItemsIndex)
                            HStack {
                                if vm.videoItemsIndex != -1 {
                                    Text("前")
                                    NavigationLink(destination:  timeSettingView(
                                        title: "クリップの前に映像を含める秒数",
                                        selection: $vm.videoItems[vm.videoItemsIndex].timeBeforeClip)){
                                            ButtonView("\(vm.videoItems[vm.videoItemsIndex].timeBeforeClip.name)")
                                        }
                                } else {
                                    Group {
                                        Text("前")
                                        ButtonView("\(SecondsKind.three.name)")
                                    }
                                    .opacity(0.0)
                                }
                            }
                            
                            HStack {
                                if vm.videoItemsIndex != -1 {
                                    Text("後")
                                    NavigationLink(destination: timeSettingView(
                                        title: "クリップの後に映像を含める秒数",
                                        selection: $vm.videoItems[vm.videoItemsIndex].timeAfterClip)) {
                                            ButtonView("\(vm.videoItems[vm.videoItemsIndex].timeAfterClip.name)")
                                        }
                                } else {
                                    Group {
                                        Text("後")
                                        ButtonView("\(SecondsKind.three.name)")
                                    }
                                    .opacity(0.0)
                                }
                            }
                            .padding(.leading, 20.0)
                        }
                        if vm.videoItemsIndex != -1 {
                            Toggle("このクリップを出力に含める", isOn: $vm.videoItems[vm.videoItemsIndex].isOutput)
                                .frame(width: sc.width * 0.8)
                        } else {
                            Toggle("このクリップを出力に含める", isOn: $vm.isPlayable)
                                .opacity(0.0)
                        }
                        NavigationLink(destination: ClipListView(videoItems: $vm.videoItems, avAsset: vm.asset)) {
                            ButtonView("リスト形式で表示する", color: .blue, selectable: true, bold: true)
                        }
                        .navigationTitle("クリップ編集")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    let exporter = ClipsSaveToPhotoLibrary(asset: vm.asset)
                                    vm.videoItems.forEach {
                                        if $0.isOutput {
                                            exporter.fetch(range: $0.range)
                                        }
                                    }
                                } label: {
                                    Text("出力")
                                }
                            }
                        }
                        Spacer()
                        VideoPlayButtonsView(viewModel: vm)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            // 「対象のゲーム」などを選択するために、別Viewに遷移したときにonDisappearが走ってしまい、CurrentItemがnilになってしまうので
            // このViewに戻ってきたときに再度playerにplayerItemを指定する
            vm.player.replaceCurrentItem(with: vm.playerItem)
        }
        .onDisappear {
            // libraryViewに戻ったときに、動画が裏で再生され続けてしまうのでCurrentItemをnilにする
            vm.player.replaceCurrentItem(with: nil)
        }
    }
}
