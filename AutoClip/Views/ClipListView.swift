//
//  ClipListView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/31.
//

import SwiftUI
import AVFoundation

struct ClipListView: View {
    @Binding var videoItems: [VideoItem]
    var avAsset: AVAsset
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(Array(videoItems.enumerated()), id: \.offset) { i, item in
                    ClipItemView(vm: .init(title: "クリップ\(i + 1)", videoItem: item, avAsset: avAsset))
                }
            }
            Spacer()
        }
    }
}
