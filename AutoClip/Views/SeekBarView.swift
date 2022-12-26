//
//  SeekBarView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/21.
//

import SwiftUI
import AVFoundation

struct SeekBarView: View {
    let sc = UIScreen.main.bounds
    @Binding var positionX: Double
    @Binding var detectedClipRanges: [CMTimeRange]
    let videoTime: CMTime
    
    init(value positionX: Binding<Double>, detectedClipRanges: Binding<[CMTimeRange]>, videoTime: CMTime) {
        _positionX = positionX
        _detectedClipRanges = detectedClipRanges
        self.videoTime = videoTime
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(width: sc.width * 0.9, height: 10)
                .cornerRadius(30.0)
            
            ForEach(0..<detectedClipRanges.count, id: \.self) { index in
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(height: 6)
                    .frame(width: getWidthSize(startVal: detectedClipRanges[index].start.value, endVal: detectedClipRanges[index].end.value, videoTimeVal: videoTime.value))
                    .cornerRadius(30.0)
                    .offset(x: getHighlightPosition(startVal: detectedClipRanges[index].start.value, videoTimeVal: videoTime.value))
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
                            //print(sc.width * 0.9)
                            if !(value.location.x < 0.0 || value.location.x > sc.width * 0.9) {
                                positionX = value.location.x
                                //print("true", value.location.x)
                                print("true", positionX)
                            } else {
                                if value.location.x < 0.0 {
                                    positionX = 0.0
                                } else if value.location.x > sc.width * 0.9 {
                                    positionX = sc.width * 0.9
                                }
                                //print("false", value.location.x)
                                print("false", positionX)
                            }
                        })
                )
        }
    }
    
    // シークバー上でハイライトされる位置を取得する
    // offsetでx座標をどのくらいずらせばいいのかを返す
    func getHighlightPosition(startVal: CMTimeValue, videoTimeVal: CMTimeValue) -> CGFloat {
        return (CGFloat(startVal) * (sc.width * 0.9)) / CGFloat(videoTimeVal)
    }
    
    func getWidthSize(startVal: CMTimeValue, endVal: CMTimeValue, videoTimeVal: CMTimeValue) -> CGFloat {
        let start = getHighlightPosition(startVal: startVal, videoTimeVal: videoTimeVal)
        let end = getHighlightPosition(startVal: endVal, videoTimeVal: videoTimeVal)
        let width = end - start
        return width
    }
}

struct SeekBarView_Previews: PreviewProvider {
    @State static var value = 0.0
    @StateObject private static var vm = ViewModel()
    
    static var previews: some View {
        SeekBarView(value: $value, detectedClipRanges: .constant(vm.testData), videoTime: vm.testVideoTime)
    }
    
    private class ViewModel: ObservableObject {
        @Published var value: Double = 0.0
        @Published var testData: [CMTimeRange]
        let testVideoTime: CMTime
        
        init() {
            testData = [
                .init(start: CMTimeMakeWithSeconds(120, preferredTimescale: 600), end: CMTimeMakeWithSeconds(360, preferredTimescale: 600)),
                .init(start: CMTimeMakeWithSeconds(540, preferredTimescale: 600), end: CMTimeMakeWithSeconds(700, preferredTimescale: 600)),
                .init(start: CMTimeMakeWithSeconds(840, preferredTimescale: 600), end: CMTimeMakeWithSeconds(1300, preferredTimescale: 600)),
                .init(start: CMTimeMakeWithSeconds(1500, preferredTimescale: 600), end: CMTimeMakeWithSeconds(1900, preferredTimescale: 600)),
                .init(start: CMTimeMakeWithSeconds(2400, preferredTimescale: 600), end: CMTimeMakeWithSeconds(7200, preferredTimescale: 600)),
            ]
            testVideoTime = .init(seconds: 7200, preferredTimescale: 600)
        }
    }
}
