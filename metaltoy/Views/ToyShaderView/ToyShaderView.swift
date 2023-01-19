//
//  ToyShaderView.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/12/23.
//

import SwiftUI

struct ToyShaderView: View {
    @Binding var shader: String
    @State var lastError: Error?
    var scale: Float = 1
    
    var body: some View {
        MetalView(shader: $shader, lastError: $lastError, scale: scale)
            .overlay {
                // TODO: Improve error text. Only display the compiler output
                lastError != nil ? ErrorOverlay(text: "\(lastError!)") : nil
            }
    }
}

struct ToyShaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToyShaderView(shader: .constant(defaultShader1))
                .previewDisplayName("Default Shader")
            
            ToyShaderView(shader: .constant("This is a syntaz error"))
                .previewDisplayName("Syntax Error")
            
            ToyShaderView(shader: .constant(defaultShader1), scale: 2)
                .previewDisplayName("Scale 2x")
            
            ToyShaderView(shader: .constant(defaultShader1), scale: 0.5)
                .previewDisplayName("Scale 0.5x")
        }
    }
}
