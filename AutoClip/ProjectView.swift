//
//  ProjectView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/07.
//

import SwiftUI

struct ProjectView: View {
    let projectName: String
    let gameName: String
    let image: Image
    let movieTime: String
    let clips: Int
    @State var backSize: CGRect = .zero
    
    let sc = UIScreen.main.bounds
    
    init(projectName: String, gameName: String, image: Image, movieTime: String, clips: Int) {
        self.projectName = projectName
        self.gameName = gameName
        self.image = image
        self.movieTime = movieTime
        self.clips = clips
    }
    
    var body: some View {
        back
            .overlay(
                HStack(spacing: 10) {
                    image
                        .resizable()
                        .frame(width: backSize.width / 3, height: backSize.width / 3)
                        .overlay (
                            Text(movieTime)
                                .bold()
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.all, 3)
                                .background(
                                    Color.black
                                        .opacity(0.6)
                                )
                            ,alignment: .bottomLeading
                        )
                        .padding()
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer()
                        Text(projectName)
                            .bold()
                            .foregroundColor(.black)
                            .font(.title2)
                            .opacity(0.7)
                        Text(gameName)
                            .foregroundColor(
                                Color(red: 0.0, green: 0.0, blue: 1.0)
                            )
                        Spacer()
                        HStack {
                            Image(systemName: "paperclip")
                            Text("\(clips)")
                        }
                        .foregroundColor(.black)
                        .opacity(0.6)
                        Spacer()
                    }
                }
                ,alignment: .leading
            )
    }
    
    var back: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .onAppear {
                        self.backSize = geo.frame(in: .global)
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .background (
                        LinearGradient (
                            colors: [Color(uiColor: UIColor(red: 0.659, green: 0.878, blue: 1.0, alpha: 1.0)), Color(uiColor: UIColor(red: 0.494, green: 0.82, blue: 1.0, alpha: 1.0))],
                            startPoint: UnitPoint(x: 0.3, y: 0.3),
                            endPoint: UnitPoint(x: 0.7, y: 0.7)
                        )
                    )
            }
            .cornerRadius(15.0)
        }
        .frame(width: sc.width * 0.9, height: sc.height * 0.2)
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(projectName: "movie01", gameName: "Apex Legends", image: Image("test"), movieTime: "40:00", clips: 10)
    }
}
