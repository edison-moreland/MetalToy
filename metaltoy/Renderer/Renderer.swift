//
//  Renderer.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/11/23.
//

import Foundation
import MetalKit
import simd
import Combine

class Renderer: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    var renderPipelineState: MTLRenderPipelineState!
    
    let lastGPUTime = CurrentValueSubject<TimeInterval, Never>(.infinity)
    let lastFrameTime = CurrentValueSubject<TimeInterval, Never>(.infinity)
    var frameStartTime: Date!
    
    var currentUserShader: String = ""
    
    var vertexBuffer: MTLBuffer!
    var vertices: [Vertex] = [
        Vertex(position: vector_float2(-1.0, -3.0)),
        Vertex(position: vector_float2(-1.0, 1.0)),
        Vertex(position: vector_float2(3.0, 1.0))
    ]
    
    var renderStartTime: Date!
    var fragmentParameters: FragmentParameters!
    
    init(device: MTLDevice, scale: Float) {
        super.init()
        
        createCommandQueue(device: device)
        createPipelineDescriptor(device: device)
        try! updatePipeline(device: device)
        createBuffers(device: device)
        
        renderStartTime = Date()
        fragmentParameters = FragmentParameters()
        fragmentParameters.scale = scale
    }
    
    func updateUserShader(device: MTLDevice, source: String) throws {
        currentUserShader = source
        let preload = try self.compileDynamicLibrary(device: device, source: source)
        try self.updatePipeline(device: device, fragmentPreload: preload)
    }
    
    //MARK: Builders
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func compileDynamicLibrary(device: MTLDevice, source: String) throws -> MTLDynamicLibrary {
        let dynCompileOptions = MTLCompileOptions()
        dynCompileOptions.libraryType = .dynamic
        dynCompileOptions.installName = "@executable_path/userCreatedDylib.metallib"
        
        let library = try device.makeLibrary(source: source, options: dynCompileOptions)
        library.label = "UserLibrary"
        
        let dynLibrary = try device.makeDynamicLibrary(library: library)
        dynLibrary.label = "UserDynLibrary"
        
        return dynLibrary
    }
    
    func createPipelineDescriptor(device: MTLDevice) {
        let library = try! device.makeLibrary(URL: Bundle.main.url(forResource: "MetalToyShaders", withExtension: ".metallib")!)
        library.label = "BaseLibrary"
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "ToyPipeline"
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")!
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")!
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        self.renderPipelineDescriptor = pipelineDescriptor
    }
    
    func updatePipeline(device: MTLDevice, fragmentPreload: MTLDynamicLibrary? = nil) throws {
        if let preload = fragmentPreload {
            self.renderPipelineDescriptor.fragmentPreloadedLibraries = [preload]
        }
        
        self.renderPipelineState = try device.makeRenderPipelineState(descriptor: self.renderPipelineDescriptor)
    }
    
    func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
        vertexBuffer.label = "WholeScreenTriangle"
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        fragmentParameters.viewport = vector_float2(
            Float(size.width),
            Float(size.height)
        )
    }
    
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor else {
                return
        }
        
        fragmentParameters.time = Float(Date().timeIntervalSince(self.renderStartTime))
        
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "ToyCommandBuffer"
        
        frameStartTime = Date()
        commandBuffer?.addCompletedHandler { commandBuffer in
            self.lastGPUTime.send(TimeInterval(commandBuffer.gpuEndTime - commandBuffer.gpuStartTime))
            self.lastFrameTime.send(Date().timeIntervalSince(self.frameStartTime))
        }
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.label = "ToyCommandEncoder"
        commandEncoder?.pushDebugGroup("ToyShaderDraw")
        
        commandEncoder?.setRenderPipelineState(renderPipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setFragmentBytes(&fragmentParameters, length: MemoryLayout<FragmentParameters>.size, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
