//
//  SettingView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/08.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: 0, label: Text("テンプレートマッチングを行う間隔")) {
                    
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
