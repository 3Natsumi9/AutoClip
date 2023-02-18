//
//  SettingView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/08.
//

import SwiftUI

struct SettingView: View {
    @State var selection: SecondsKind = .three
    @State var customValue = 0
    var body: some View {
        NavigationView {
            Form {
                Picker("クリップの前に映像を含める秒数", selection: $selection) {
                    let kinds = SecondsKind.allCases
                    
                    ForEach(kinds, id: \.self) { kind in
                        Text(kind.name).tag(kind)
                    }
                }
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
