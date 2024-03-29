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
    @Environment(\.dismiss) private var dismiss
    @State var isShowDialog = false
    @State var isShowOutputResultDialog = false
    @State var isShowOutputTargetIsEmptyDialog = false
    @State var isBackButtonTapped = false
    @State var outputResults: [Bool] = []
    @State var isOutputting = false
    
    let sc = UIScreen.main.bounds
    
    var body: some View {
        VStack {
            if !vm.isPlayable {
                ProgressView()
            } else {
                ZStack {
                    VStack {
                        // 16:9にする
                        VideoPlayerController(player: vm.player)
                            .frame(width: sc.width, height: CGFloat((sc.width * 9) / 16))
                        VStack(spacing: 35) {
                            SeekBarView(viewModel: vm)
                            HStack(spacing: 5) {
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
                                        isShowDialog = true
                                    } label: {
                                        Text("保存")
                                    }
                                }
                            }
                            .confirmationDialog("アクションを選択してください", isPresented: $isShowDialog, titleVisibility: .visible) {
                                Button("プロジェクトの保存") {
                                    vm.saveProjectToDB()
                                    let numberOfProject = UserDefaults.standard.integer(forKey: "NumberOfProject")
                                    UserDefaults.standard.set(numberOfProject + 1, forKey: "NumberOfProject")
                                }
                                Button("クリップ出力") {
                                    if vm.videoItems.filter({ $0.isOutput == true }).count == 0 {
                                        isShowOutputTargetIsEmptyDialog = true
                                        return
                                    }
                                    isOutputting = true
                                    vm.player.pause()
                                    outputResults.removeAll()
                                    let exporter = ClipsSaveToPhotoLibrary(asset: vm.asset)
                                    
                                    exporter.cancellable = exporter.resultPublisher.sink {
                                        outputResults.append($0)
                                        
                                        if outputResults.count == vm.videoItems.filter({ $0.isOutput == true }).count {
                                            vm.player.play()
                                            isOutputting = false
                                            isShowOutputResultDialog = true
                                        }
                                    }
                                    
                                    vm.videoItems.forEach {
                                        if $0.isOutput {
                                            exporter.fetch(range: $0.range)
                                        }
                                    }
                                }
                            } message: {
                                Text("")
                            }
                            .alert("出力処理が完了しました", isPresented: $isShowOutputResultDialog) {
                                Button("OK") {}
                            } message: {
                                Text("\(vm.videoItems.filter({ $0.isOutput == true }).count)個中\(outputResults.filter({ $0 == true }).count)個の出力に成功しました")
                            }
                            .alert("エラー", isPresented: $isShowOutputTargetIsEmptyDialog) {
                                Button("OK") {}
                            } message: {
                                Text("出力対象の動画が存在しませんでした。\n「このクリップを出力に含める」をオンにして再度お試しください")
                            }
                            .alert("保存完了", isPresented: $vm.isSaveFinished) {
                                Button("OK") {}
                            } message: {
                                Text("保存処理が完了しました")
                            }
                            
                            Spacer()
                            VideoPlayButtonsView(viewModel: vm)
                        }
                        Spacer()
                    }
                    if vm.isSaving || isOutputting {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                            .opacity(0.51)
                        
                        ProgressView()
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading:
                        Button {
                            isBackButtonTapped = true
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                    .font(Font.system(size: 16, design: .serif))
                                    .padding(.leading, -6)
                                Text("戻る")
                            }
                        }
                )
                .alert("警告", isPresented: $isBackButtonTapped) {
                    Button("OK") { dismiss() }
                    Button("Cancel") {}
                } message: {
                    Text("保存されていないデータは失われますがよろしいですか？")
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
    }
}
