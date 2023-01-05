//
//  ContentView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/07.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var vm = TestViewModel()
    
    var body: some View {
        SeekBarView(playTime: $vm.playTime, detectedClipRanges: $vm.testData, videoTime: vm.testVideoTime)
    }
}

class TestViewModel: ObservableObject {
    @Published var playTime: CMTime = .init(seconds: 0.0, preferredTimescale: 600)
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
