//
//  ClipDetectionView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/09.
//

import SwiftUI
import AVKit

struct ClipDetectionView: View {
    let asset = NSDataAsset(name: "splatoon")
    let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("splatoon.mp4")
    let item: AVPlayerItem
    let player: AVPlayer
    let maximumValue: Float
    let sc = UIScreen.main.bounds
    
    init() {
        try! asset!.data.write(to: videoUrl)
        item = AVPlayerItem(url: videoUrl)
        player = AVPlayer(playerItem: item)
        maximumValue = Float(CMTimeGetSeconds(item.duration))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15.0) {
                // VideoPlayerのサイズを16:9にする
                // frame指定しないと、縦幅が余分に取られてしまう
                VideoPlayer(player: player)
                    .frame(width: sc.width, height: CGFloat((sc.width * 9) / 16))
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("対象のゲーム")
                                .font(.system(size: 16))
                            NavigationLink(destination: EmptyView()) {
                                ButtonView("Apex Legends")
                            }
                        }
                        VStack {
                            Text("切り抜くシーン")
                                .font(.system(size: 16))
                            NavigationLink(destination: EmptyView()) {
                                ButtonView("キル")
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
                                    NavigationLink(destination: EmptyView()) {
                                        ButtonView("3秒")
                                    }
                                }
                                HStack {
                                    Text("後")
                                    NavigationLink(destination: EmptyView()) {
                                        ButtonView("5秒")
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
                            NavigationLink(destination: EmptyView()) {
                                ButtonView("3秒")
                            }
                        }
                        
                        HStack {
                            Spacer()
                            NavigationLink(destination: EmptyView()) {
                                ButtonView("検出開始！", color: .red, selectable: false, bold: true)
                                
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 15.0)
                    .navigationTitle("クリップ検出")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

struct ClipDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ClipDetectionView()
    }
}
