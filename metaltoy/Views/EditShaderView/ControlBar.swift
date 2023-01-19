//
//  ControlBar.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/13/23.
//

import SwiftUI
import ViewExtractor

struct ControlBar<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        Extract(content) { views in
            HStack(spacing: 0) {
                ForEach(views) { view in
                    view
                }
                
                Spacer()
            }.background(.bar)
        }
    }
}

struct ControlBar_Previews: PreviewProvider {
    static var previews: some View {
        ControlBar() {
            ControlButton(icon: "play") {}
            ControlButton(icon: "pause") {}
        }
    }
}
