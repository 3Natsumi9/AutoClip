//
//  SeekBarView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/21.
//

import SwiftUI
import AVFoundation

struct SeekBarView: View {
    @State var positionX = 0.0
    @State var isDragging = false
    @ObservedObject var vm: ClipEditingViewModel
    let manager = VideoSeekManager()
    let sc = UIScreen.main.bounds
    
    init(viewModel vm: ClipEditingViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: sc.width * 0.9, height: 10)
                    .cornerRadius(30.0)
                
                // 検出したクリップの位置に黄色いViewを重ねてハイライトする
                ForEach(0..<vm.detectedClipRanges.count, id: \.self) { index in
                    Rectangle()
                        .foregroundColor(.yellow)
                        .frame(height: 6)
                        .frame(width: getWidthSize(startVal: vm.detectedClipRanges[index].start.value, endVal: vm.detectedClipRanges[index].end.value, videoTimeVal: vm.videoTime.value))
                        .cornerRadius(30.0)
                        .offset(x: getHighlightPosition(startVal: vm.detectedClipRanges[index].start.value, videoTimeVal: vm.videoTime.value))
                }
                
                Circle()
                    .foregroundColor(.gray)
                    .opacity(0.95)
                    .frame(width: 20, height: 20)
                    .offset(x: positionX)
                    .offset(x: -10)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                isDragging = true
                                if !(value.location.x < 0.0 || value.location.x > sc.width * 0.9) {
                                    positionX = value.location.x
                                } else {
                                    // つまみを左端に動かしても、綺麗に0.0にならないことが多かった(右端も同様)ので、
                                    // シークバーを越えた位置まで指を動かした場合はそれぞれ最小値、最大値になる様にした
                                    if value.location.x < 0.0 {
                                        positionX = 0.0
                                    } else if value.location.x > sc.width * 0.9 {
                                        positionX = sc.width * 0.9
                                    }
                                }
                                vm.seekBarChanged(cmTime: convertPositionXToCMTime(position: positionX, videoTime: vm.videoTime))
                            })
                            .onEnded({ _ in
                                isDragging = false
                                vm.clipRangesIndex = manager.getClipRangesIndex(playTime: convertPositionXToCMTime(position: positionX, videoTime: vm.videoTime), seekTimes: vm.seekTimes)
                                vm.videoItemsIndex = vm.videoItems.searchIndex(playTime: convertPositionXToCMTime(position: positionX, videoTime: vm.videoTime))
                                print("clipRangesIndex:", vm.clipRangesIndex)
                                print("playTime:", vm.playTime)
                            })
                    )
            }
            
            Text("\(vm.playTime.time) / \(vm.videoTime.time)")
                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)))
        }
        .onChange(of: vm.playTime) { time in
            if !isDragging {
                positionX = convertCMTimeToPositionX(playTime: time, videoTime: vm.videoTime)
                            print("positionX:", positionX)
            }
        }
    }
    
    // シークバー上でハイライトされる位置を取得する
    // offsetでx座標をどのくらいずらせばいいのかを返す
    func getHighlightPosition(startVal: CMTimeValue, videoTimeVal: CMTimeValue) -> CGFloat {
        print("startVal:", startVal)
        print("videoTimeVal:", videoTimeVal)
        return (CGFloat(startVal) * (sc.width * 0.9)) / CGFloat(videoTimeVal)
    }
    
    // ハイライトされるViewのサイズを取得する
    func getWidthSize(startVal: CMTimeValue, endVal: CMTimeValue, videoTimeVal: CMTimeValue) -> CGFloat {
        print(startVal, endVal, videoTimeVal)
        let start = getHighlightPosition(startVal: startVal, videoTimeVal: videoTimeVal)
        let end = getHighlightPosition(startVal: endVal, videoTimeVal: videoTimeVal)
        let width = end - start
        return width
    }
    
    // 変数PositionXをCMTimeに変換する
    // シークバー上のつまみの位置から動画で言う何分何秒を指しているのかを取得する
    func convertPositionXToCMTime(position: Double, videoTime: CMTime) -> CMTime {
        // 370 : 30 = 720000 : x
        let value = position * Double(videoTime.value) / Double(sc.width * 0.9)
        let cmTime = CMTime(value: CMTimeValue(value), timescale: videoTime.timescale)
        return cmTime
    }
    
    // 370 : x = 720000 : 12000
    // CMTimeをPositionXに変換する
    func convertCMTimeToPositionX(playTime: CMTime, videoTime: CMTime) -> CGFloat {
        print("calcurate:", "(\(CGFloat(playTime.value)) * \(CGFloat(sc.width * 0.9))) / \(CGFloat(videoTime.value)) = \((CGFloat(playTime.value) * CGFloat(sc.width * 0.9)) / CGFloat(videoTime.value))")
        let position = (CGFloat(playTime.value) * CGFloat(sc.width * 0.9)) / CGFloat(videoTime.value)
        return position
    }
}

extension CMTime {
    var time: String {
        let cmTimeSeconds = CMTimeGetSeconds(self).isNaN ? 0 : CMTimeGetSeconds(self)
        
        let hours = cmTimeSeconds / 3600.0
        let minutes = hours.truncatingRemainder(dividingBy: 1) * 60
        let seconds = minutes.truncatingRemainder(dividingBy: 1) * 60
        
        if Int(hours) > 0 {
            return String(format: "%d:%02d:%02d.%02d", Int(hours), Int(minutes), Int(seconds), Int(seconds.truncatingRemainder(dividingBy: 1) * 100))
        } else {
            return String(format: "%d:%02d.%02d", Int(minutes), Int(seconds), Int(seconds.truncatingRemainder(dividingBy: 1) * 100))
        }
    }
}

//struct SeekBarView_Previews: PreviewProvider {
//    @StateObject private static var vm = TestViewModel()
//
//    init() {
//        SeekBarView_Previews.vm.seekTimes = getSeekTimes(detectedClipRanges: SeekBarView_Previews.vm.testData, videoTime: SeekBarView_Previews.vm.testVideoTime)
//    }
//
//    static var previews: some View {
//        SeekBarView(playTime: $vm.playTime, detectedClipRanges: $vm.testData, seekTimes: $vm.seekTimes, clipRangesIndex: $vm.clipRangesIndex, videoTime: $vm.testVideoTime)
//    }
//    
//    class TestViewModel: ObservableObject {
//        @Published var playTime: CMTime = .init(seconds: 0.0, preferredTimescale: 600)
//        @Published var testData: [CMTimeRange]
//        @Published var clipRangesIndex: Int = 0
//        @Published var seekTimes: [CMTimeRange] = []
//        @Published var testVideoTime: CMTime
//
//
//        init() {
//            testData = [
//                .init(start: CMTimeMakeWithSeconds(120, preferredTimescale: 600), end: CMTimeMakeWithSeconds(360, preferredTimescale: 600)),
//                .init(start: CMTimeMakeWithSeconds(540, preferredTimescale: 600), end: CMTimeMakeWithSeconds(700, preferredTimescale: 600)),
//                .init(start: CMTimeMakeWithSeconds(840, preferredTimescale: 600), end: CMTimeMakeWithSeconds(1300, preferredTimescale: 600)),
//                .init(start: CMTimeMakeWithSeconds(1500, preferredTimescale: 600), end: CMTimeMakeWithSeconds(1900, preferredTimescale: 600)),
//                .init(start: CMTimeMakeWithSeconds(2400, preferredTimescale: 600), end: CMTimeMakeWithSeconds(7200, preferredTimescale: 600)),
//            ]
//            testVideoTime = .init(seconds: 10000, preferredTimescale: 600)
//        }
//    }
//}
