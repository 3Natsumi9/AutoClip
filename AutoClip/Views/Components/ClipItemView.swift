//
//  ClipItemView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/01/29.
//

import SwiftUI

struct ClipItemView: View {
    let sc = UIScreen.main.bounds
    @StateObject var vm: ClipItemViewModel
    
    var body: some View {
        VStack {
            HStack {
                HStack(alignment: .top) {
                    Image(uiImage: vm.thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: sc.width * 0.35)
                        .padding(.horizontal, 10)
                    VStack(alignment: .leading) {
                        Text("\(vm.title)")
                            .bold()
                        Text("\(vm.videoItem.range.start.time) - \(vm.videoItem.range.end.time)")
                    }
                }
                
                Spacer()
                Toggle("", isOn: $vm.videoItem.isOutput)
                    .fixedSize()
                    .padding(.trailing, 20)
            }
            Divider()
        }
    }
}
