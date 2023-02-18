//
//  gameSceneSettingView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/13.
//

import SwiftUI

struct gameSceneSettingView: View {
    let kinds = GameSceneKind.allCases
    @Binding var selection: GameSceneKind
    var body: some View {
        Form {
            Picker("切り抜くシーンを選択", selection: $selection) {
                ForEach(kinds, id: \.self) { kind in
                    Text(kind.name).tag(kind)
                }
            }
            .pickerStyle(.inline)
        }
    }
}

struct gameSceneSettingView_Previews: PreviewProvider {
    @State static var selection: GameSceneKind = .kill
    static var previews: some View {
        gameSceneSettingView(selection: $selection)
    }
}
