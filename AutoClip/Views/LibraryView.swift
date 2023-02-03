//
//  LibraryView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/07.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                        ProjectView(projectName: "test", gameName: "hoge", image: Image("test"), movieTime: "30:00", clips: 3)
                                            ProjectView(projectName: "test", gameName: "hoge", image: Image("test"), movieTime: "30:00", clips: 3)
                    
                   
                }
                    .navigationTitle("ライブラリ")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                
                            } label: {
                                Text("追加")
                            }
                        }
                }
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
