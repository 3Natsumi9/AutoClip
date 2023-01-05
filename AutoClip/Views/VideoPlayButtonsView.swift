//
//  VideoPlayButtonsView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/04.
//

import SwiftUI

struct VideoPlayButtonsView: View {
    @State var isPlaying = false
    
    let sc = UIScreen.main.bounds
    var body: some View {
        HStack(spacing: 40) {
            Button {
                
            } label:{
                Image(systemName: "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sc.width * 0.18)
            }
            Button {
                isPlaying.toggle()
            } label:{
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sc.width * 0.185)
            }
            Button {
                
            } label:{
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sc.width * 0.18)
            }
        }
        .foregroundColor(.black)
    }
}

struct VideoPlayButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayButtonsView()
    }
}
