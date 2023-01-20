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
    var help: String
    var icon: String
    var callback: () -> Void
    
    init(_ help: String, icon: String, callback: @escaping () -> Void) {
        self.help = help
        self.icon = icon
        self.callback = callback
    }
    
    var body: some View {
        Button(action: callback) {
            Image(systemName: icon)
        }
        .buttonStyle(ColoredButton(.secondary, pressedColor: .primary))
        .help(help)
    }
}

struct ControlBar<LeadingContent: View, TrailingContent: View>: View {
    @ViewBuilder let leading: LeadingContent
    @ViewBuilder let trailing: TrailingContent
    
    var body: some View {
        HStack(spacing: 0) {
            Extract(leading) { views in
                HStack(spacing: 0) {
                    ForEach(views) { view in
                        view
                            .frame(width: 40,
                                   height: 40)
                    }
                }
            }
            Spacer()
            Extract(trailing) { views in
                HStack(spacing: 0) {
                    ForEach(views) { view in
                        view
                            .frame(width: 40,
                                   height: 40)
                    }
                }
            }
        }
        .font(.system(size: 15, weight: .heavy))
        .background(.bar)
    }
}

struct ControlBar_Previews: PreviewProvider {
    static var previews: some View {
        let icons: [String] = [
            "play", "pause", "square.and.arrow.down", "doc"
        ]
        
        ControlBar(leading: {
            ForEach(icons, id: \.self) {icon in
                ControlButton(icon, icon: icon) {}
            }
        }, trailing: {
        })
    }
}
