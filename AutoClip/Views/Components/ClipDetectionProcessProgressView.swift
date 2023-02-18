//
//  ClipDetectionProcessProgressView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/13.
//

import SwiftUI

struct ClipDetectionProcessProgressView: View {
    let sc = UIScreen.main.bounds
    @Binding var progress: Float
    var body: some View {
        ZStack {
            Color.black
                .blur(radius: 30)
                .frame(width: sc.width * 0.65, height: sc.width * 0.5)
                .opacity(0.2)
                .cornerRadius(10)
                .overlay(
                    GeometryReader { geo in
                        VStack(spacing: 15) {
                            Text("クリップ検出中...")
                                .bold()
                            ProgressView()
                            ProgressView("", value: progress, total: 100.0)
                                .frame(width: geo.size.width * 0.9)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                )
        }
    }
}
