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
            VStack {
               
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

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
