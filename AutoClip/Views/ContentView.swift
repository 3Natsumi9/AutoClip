//
//  ContentView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/07.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                LibraryView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "books.vertical")
                    Text("ライブラリ")
                }
            }
            NavigationView {
                SettingView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "gearshape")
                    Text("設定")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
