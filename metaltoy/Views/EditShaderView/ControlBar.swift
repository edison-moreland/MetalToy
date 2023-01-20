//
//  ControlBar.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/13/23.
//

import SwiftUI
import ViewExtractor

struct ColoredButton : ButtonStyle {
    var defaultColor: Color
    var pressedColor: Color
    
    init(_ defaultColor: Color, pressedColor: Color) {
        self.defaultColor = defaultColor
        self.pressedColor = pressedColor
    }
 
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? defaultColor : pressedColor)
    }
}

struct ControlButton: View {
    static var buttonSize: CGFloat = 40
    
    var icon: String
    var callback: () -> Void
    
    var body: some View {
        Button(action: callback) {
            Image(systemName: icon)
                .font(.system(size: 15, weight:.heavy))
                .frame(width: ControlButton.buttonSize,
                       height: ControlButton.buttonSize)
        }
        .buttonStyle(ColoredButton(.secondary, pressedColor: .primary))
    }
}

struct ControlBar<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        Extract(content) { views in
            HStack(spacing: 0) {
                ForEach(views) { view in
                    view
                }
            }.background(Material.bar)
        }
    }
}

struct ControlBar_Previews: PreviewProvider {
    static var previews: some View {
        let icons: [String] = [
            "play", "pause", "square.and.arrow.down", "doc"
        ]
        
        ControlBar {
            ForEach(icons, id: \.self) {icon in
                ControlButton(icon: icon) {}
            }
        }.frame(width: ControlButton.buttonSize*CGFloat(icons.count))
    }
}
