//
//  SettingView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/08.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var settings: Settings
    var body: some View {
        Form {
            Picker("クリップの前に映像を含める秒数", selection: $settings.timeBeforeClip) {
                let kinds = SecondsKind.allCases
                
                ForEach(kinds, id: \.self) { kind in
                    Text(kind.name).tag(kind)
                }
            }
            Picker("クリップの後に映像を含める秒数", selection: $settings.timeAfterClip) {
                let kinds = SecondsKind.allCases
                
                ForEach(kinds, id: \.self) { kind in
                    Text(kind.name).tag(kind)
                }
            }
            Picker("マッチング処理を行う間隔", selection: $settings.matchingProcessInterval) {
                let kinds = { () -> [SecondsKind] in
                    var results = SecondsKind.allCases
                    let ignoreTimes: [SecondsKind] = [.zero, .twenty, .twentyfive, .thirty, .fourty, .fifty, .sixty]
                    for time in ignoreTimes {
                        results.removeAll(where: {
                            $0 == time
                        })
                    }
                    return results
                }()
                
                ForEach(kinds, id: \.self) { kind in
                    Text(kind.name).tag(kind)
                }
            }
        }
        .navigationTitle("設定")
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(Settings.shared)
    }
}
