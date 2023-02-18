//
//  timeSettingView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/23.
//

import SwiftUI

struct timeSettingView: View {
    let title: String
    let kinds: [SecondsKind]
    @Binding var selection: SecondsKind
    @Environment(\.isPresented) var isPresented
    
    init(title: String, selection: Binding<SecondsKind>) {
        self.title = title
        self._selection = selection
        self.kinds = SecondsKind.allCases
    }
    
    init(title: String, selection: Binding<SecondsKind>, ignoreTimes: [SecondsKind]) {
        self.title = title
        self._selection = selection
        
        var results = SecondsKind.allCases
        for time in ignoreTimes {
            results.removeAll(where: {
                $0 == time
            })
        }
        self.kinds = results
    }
    
    var body: some View {
        Form {
            Picker(title, selection: $selection) {
                ForEach(kinds, id: \.self) { kind in
                    Text(kind.name).tag(kind)
                }
            }
            .pickerStyle(.inline)
        }
    }
}

struct timeSettingView_Previews: PreviewProvider {
    @State static var selection: SecondsKind = .three
    static var previews: some View {
        timeSettingView(title: "クリップの前に映像を含める秒数", selection: $selection)
    }
}
