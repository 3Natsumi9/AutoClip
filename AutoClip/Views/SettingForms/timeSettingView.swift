//
//  timeSettingView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/23.
//

import SwiftUI

struct timeSettingView: View {
    let beforeOrAfter: BeforeOrAfter
    let kinds = SecondsKind.allCases
    @Binding var selection: SecondsKind
    
    enum BeforeOrAfter {
        case before
        case after
        
        var displayText: String {
            switch self {
            case .before:
                return "クリップの前に映像を含める秒数"
            case .after:
                return "クリップの後に映像を含める秒数"
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Picker(beforeOrAfter.displayText, selection: $selection) {
                    ForEach(kinds) { kind in
                        Text(kind.name).tag(kind)
                                    }
                }
                .pickerStyle(.inline)
            }
        }
    }
}

struct timeSettingView_Previews: PreviewProvider {
    @State static var selection: SecondsKind = .three
    static var previews: some View {
        timeSettingView(beforeOrAfter: .before, selection: $selection)
    }
}
