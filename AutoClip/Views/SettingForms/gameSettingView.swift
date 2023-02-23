//
//  gameSettingView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/13.
//

import SwiftUI

struct gameSettingView: View {
    let kinds = GameKind.allCases
    @Binding var selection: GameKind
    var body: some View {
        Form {
            Picker("ゲームを選択", selection: $selection) {
                ForEach(kinds, id: \.self) { kind in
                    Text(kind.name).tag(kind)
                }
            }
            .pickerStyle(.inline)
        }
    }
}

struct gameSettingView_Previews: PreviewProvider {
    @State static var selection: GameKind = .splatoon
    static var previews: some View {
        gameSettingView(selection: $selection)
    }
}
