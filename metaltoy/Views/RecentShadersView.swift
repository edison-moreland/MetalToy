//
//  RecentShadersView.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/14/23.
//

import SwiftUI

struct RecentShadersView: View {
    let recentShaders: [ToyShader]
    
    var body: some View {
        GridHelper(width: 5, height: 2) { i in
            RecentShaderFrame {
                if let shader = recentShaders[safe: i] {
                    NavigationLink(value: shader) {
                        ToyShaderView(shader: shader, scale: 0.4)
                    }.buttonStyle(.borderless)
                } else {
                    NavigationLink(value: defaultShader) {
                        Image(systemName: "plus")
                            .foregroundColor(Color("AppOrange"))
                            .imageScale(.large)
                    }.buttonStyle(.borderless)
                }
            }
        }
        
    }
}

struct RecentShadersView_Previews: PreviewProvider {
    static var previews: some View {
        RecentShadersView(recentShaders: [defaultShader])
            .padding()
            .background(Color("AppWhite"))
    }
}
