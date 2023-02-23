//
//  VideoPlayButtonsView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/04.
//

import SwiftUI
import AVFoundation

struct VideoPlayButtonsView: View {
    @ObservedObject var vm: ClipEditingViewModel
    
    init(viewModel vm: ClipEditingViewModel) {
        self.vm = vm
    }
    
    let sc = UIScreen.main.bounds
    
    var body: some View {
        HStack(spacing: 40) {
            Button {
                vm.playTime.value = vm.seekTimes[vm.clipRangesIndex].start.value
                vm.player.seek(to: vm.seekTimes[vm.clipRangesIndex].start, toleranceBefore: .zero, toleranceAfter: .zero)
                vm.player.play()
            } label:{
                Image(systemName: "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sc.width * 0.18, height: sc.width * 0.18)
            }
            Button {
                if !vm.isPlay {
                    vm.player.play()
                } else {
                    vm.player.pause()
                }
            } label:{
                Image(systemName: vm.isPlay ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sc.width * 0.185, height: sc.width * 0.185)
            }
            Button {
                vm.playTime.value = vm.seekTimes[vm.clipRangesIndex].end.value
                vm.player.seek(to: vm.seekTimes[vm.clipRangesIndex].end, toleranceBefore: .zero, toleranceAfter: .zero)
                vm.player.play()
            } label:{
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sc.width * 0.18, height: sc.width * 0.18)
            }
        }
        .foregroundColor(.black)
    }
}



// 1 2 3 4 5 6 7 8 9 10
// x: 3
// 1 < x, x > 10

// 0...1000
// 1: start->10, end->100
// 2: start->200, end->600
// 3: start->700, end->800
// clipRangeIndex.count->3
// x: 5
// x > 0, x < 10 : x > 100, x < 200 : x > 600, x < 700 : x > 800, x < 1000

//
//struct VideoPlayButtonsView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayButtonsView()
//    }
//}
