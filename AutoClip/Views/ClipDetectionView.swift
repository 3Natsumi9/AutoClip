//
//  ClipDetectionView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/09.
//

import SwiftUI
import AVKit
import RealmSwift

struct ClipDetectionView: View {
    @StateObject var vm: ClipDetectionViewModel
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) private var dismiss
    @State var isBackButtonTapped = false
    @State var isSameProjectName = false
    @State var txtThreshold = "50"
    @FocusState var isActive: Bool
    let sc = UIScreen.main.bounds
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 15.0) {
                    // VideoPlayerのサイズを16:9にする
                    // frame指定しないと、縦幅が余分に取られてしまう
                    VideoPlayer(player: vm.player)
                        .frame(width: sc.width, height: CGFloat((sc.width * 9) / 16))
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("プロジェクト名")
                                    .font(.system(size: 16))
                                TextField("入力してください", text: $vm.projectName)
                                    .focused($isActive)
                                    
                            }
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
                            VStack(alignment: .leading, spacing: 7) {
                                Text("しきい値")
                                    .font(.system(size: 16))
                                Text("しきい値を変更することで、クリップ検出のされやすさや正確性を高めることができます。50-70にするのがおすすめです。")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                TextField("入力してください", text: $txtThreshold, onEditingChanged: { isEditing in
                                    if !isEditing {
                                        var tmp = Float(txtThreshold) ?? 0.0
                                        // 最大値は100
                                        if tmp > 100 {
                                            tmp = 100
                                        }
                                        // 最小値は0
                                        if tmp < 0 {
                                            tmp = 0
                                        }
                                        
                                        txtThreshold = String(Int(tmp))
                                        vm.threshold = tmp
                                    }
                                })
                                .keyboardType(.numberPad)
                                .focused($isActive)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("閉じる") {
                                            isActive = false
                                        }
                                    }
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
                            let realm = try! Realm()
                            let projectNames = realm.objects(Project.self).map{ $0.name }
                            
                            // 同じプロジェクト名は使わせない
                            projectNames.forEach {
                                if vm.projectName == $0 {
                                    isSameProjectName = true
                                    return
                                }
                            }
                            
                            if isSameProjectName {
                                return
                            }
                            
                            vm.isProgress = true
                            vm.createClipDetectionProcess(settings: settings)
                            vm.startDetection()
                        } label: {
                            ButtonView("検出開始！", color: .red, selectable: false, bold: true)
                        }
                        Spacer()
                    }
                    .alert("警告", isPresented: $isSameProjectName) {
                        Button("OK") {}
                    } message: {
                        Text("同じプロジェクト名は使えません")
                    }
                    .alert("警告", isPresented: $vm.clipDetectionFailedIs) {
                        Button("OK") {}
                    } message: {
                        Text("クリップが検出されませんでした。ゲームの種類やシーンの設定などを見直して再度お試しください")
                    }
                    Spacer()
                }
                if vm.isProgress {
                    Color.gray
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.51)
                    ClipDetectionProcessProgressView(progress: $vm.progress)
                }
                NavigationLink(destination: ClipEditingView(vm: ClipEditingViewModel(projectName: vm.projectName, game: vm.gameSelection, videoLoadedFromDB: false, videoUrl: vm.videoUrl, localIdentifier: vm.localIdentifier, detectedClipRanges: vm.detectedClipRanges)), isActive: $vm.isProcessFinished) {
                    EmptyView()
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
        }
        .alert("警告", isPresented: $isBackButtonTapped) {
            Button("OK") { dismiss() }
            Button("Cancel") {}
        } message: {
            Text("ライブラリ画面に戻りますか？")
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
