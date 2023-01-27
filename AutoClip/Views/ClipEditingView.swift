//
//  ClipEditingView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/27.
//

import SwiftUI
import AVKit

struct ClipEditingView: View {
    @StateObject var vm = ClipEditingViewModel()
    
    let sc = UIScreen.main.bounds
    
    var body: some View {
        NavigationView {
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
                                            beforeOrAfter: .before,
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
                                            beforeOrAfter: .after,
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
                            ButtonView("リスト形式で表示する", color: .blue, selectable: true, bold: true)
                            Spacer()
                            VideoPlayButtonsView(viewModel: vm)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}


struct ClipEditingView_Previews: PreviewProvider {
    static var previews: some View {
        ClipEditingView()
            .environmentObject(Settings.shared)
    }
}
