//
//  UIKitBridge.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/11/23.
//

import SwiftUI
import MetalKit
import CryptoKit
import Combine

struct MetalView: NSViewRepresentable {
    @Binding var shader: String
    @Binding var lastError: Error?
    var scale: Float = 1
    
    func makeNSView(context: Context) -> KitMetalView {
        let view = KitMetalView(scale: scale)

        return view
    }
    
    func updateNSView(_ nsView: KitMetalView, context: Context) {
        guard shader != nsView.renderer.currentUserShader else {
            return
        }
        
        var compilationError: Error? = nil
        do {
            try nsView.renderer.updateUserShader(device: nsView.device!, source: shader)
        } catch {
            compilationError = error
        }
        
        DispatchQueue.main.async {
            self.lastError = compilationError
        }
    }
}

class KitMetalView: MTKView {
    var renderer: Renderer!
    var cancellables: [AnyCancellable] = []
    
    init(scale: Float = 1) {
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        
        guard let defaultDevice = device else {
            fatalError("Device loading error")
        }
        colorPixelFormat = .bgra8Unorm
        preferredFramesPerSecond = 60
        renderer = Renderer(device: defaultDevice, scale: scale)
        delegate = renderer
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
