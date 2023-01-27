//
//  ButtonView.swift
//  AutoClip
//
//  Created by cmStudent on 2022/12/12.
//

import SwiftUI

struct ButtonView: View {
    let text: String
    let color: Colors
    let selectable: Bool
    let bold: Bool
    let sc = UIScreen.main.bounds
    
    enum Colors {
        case blue
        case red
        
        var element: Color {
            switch self {
            case .blue:
                return Color(red: 0.259, green: 0.6, blue: 1.0)
            case .red:
                return Color(red: 1.0, green: 0.102, blue: 0.369)
            }
        }
    }
    
    init(_ text: String, color: Colors = .blue, selectable: Bool = true, bold: Bool = false) {
        self.text = text
        self.color = color
        self.selectable = selectable
        self.bold = bold
    }
    
    var body: some View {
        // 透明なTextにpadding等を付けて、Viewの大きさを決定し
        // その上に実際に表示させるTextや三角形を置く
        // boldがfalseのときと、trueのときでViewの大きさが変わってしまうのが嫌だったので、
        // 透明なTextには常にboldをつけた
        Text(text)
            .foregroundColor(.clear)
            .modifier(BoldText(bold: true))
            .padding(.leading, 10.0)
            .padding(.trailing, 50.0)
            .overlay(
                HStack {
                    Text(text)
                        .foregroundColor(.white)
                        .modifier(BoldText(bold: bold))
                        .fixedSize()
                    
                    if selectable {
                        GeometryReader { geo in
                            HStack {
                                Spacer()
                                Triangle()
                                    .foregroundColor(Color(red: 0.851, green: 0.851, blue: 0.851))
                                    .frame(width: geo.size.height - 12, height: geo.size.height - 12)
                                    .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
                ,alignment: .center
            )
            .padding(.trailing, selectable ? 10.0 : 0.0)
            .padding(10.0)
            .background(color.element)
            .cornerRadius(5.0)
            
    }
    
    struct BoldText: ViewModifier {
        let bold: Bool
        
        func body(content: Content) -> some View {
            if bold {
                content
                    .font(.system(size: 18).bold())
            } else {
                content
                    .font(.system(size: 18))
            }
        }
    }
    
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            return path
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView("検出開始！", color: .blue, selectable: true, bold: true)
    }
}
