//
//  Renderer.swift
//  LifeLab
//
//  Created by Jonathan Attfield on 08/01/2021.
//

import Foundation
import MetalKit
import simd

class Renderer : NSObject, MTKViewDelegate {
    let device : MTLDevice
    let commandQueue : MTLCommandQueue
    
    let renderState : MTLRenderPipelineState
    let computeState : MTLComputePipelineState
    
    let vertexData : [Float]
    let vertexBuffer : MTLBuffer
    
    let genA : MTLTexture
    let genB : MTLTexture
    
    let cellsWide = 1000
    let cellsHigh = 1000
    
    var generation = 0
    
    var viewMatrix = matrix_identity_float4x4
    
    init(view: MTKView, device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!
        
        let library = device.makeDefaultLibrary()!
        let vertexFn = library.makeFunction(name: "vertexShader")
        let fragmentFn = library.makeFunction(name: "fragmentShader")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFn
        pipelineDescriptor.fragmentFunction = fragmentFn
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        pipelineDescriptor.sampleCount = view.sampleCount
        //let mtlVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        //pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor
        do {
            try renderState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
                fatalError("Could not create render pipeline state: \(error)")
        }
        
        let computeFn = library.makeFunction(name: "generation")!
        do {
            try computeState = device.makeComputePipelineState(function: computeFn)
        } catch {
            fatalError("Could not create compute State \(error)")
        }
        
        vertexData = [-1.0, -1.0, 0.0, 1.0,
                       1.0, -1.0, 0.0, 1.0,
                      -1.0,  1.0, 0.0, 1.0,
                      -1.0,  1.0, 0.0, 1.0,
                       1.0, -1.0, 0.0, 1.0,
                       1.0,  1.0, 0.0, 1.0]
        let dataSize = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertexData,
                                         length: dataSize,
                                         options: [])!
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.storageMode = .managed
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        textureDescriptor.pixelFormat = .r8Uint
        textureDescriptor.width = cellsWide
        textureDescriptor.height = cellsHigh
        textureDescriptor.depth = 1
        
        genA = device.makeTexture(descriptor: textureDescriptor)!
        genB = device.makeTexture(descriptor: textureDescriptor)!
        
        super.init()
       
        generation = 0
        var seed = [UInt8](repeating: 0, count: cellsWide * cellsHigh)
        let numberOfCells = cellsWide * cellsHigh
        let numberOfLiveCells = Int(pow(Double(numberOfCells), 0.8))
        for _ in (0..<numberOfLiveCells) {
            let r = (0..<numberOfCells).randomElement()!
            seed[r] = 1
        }
        currentGenerationTexture().replace(region: MTLRegionMake2D(0, 0, cellsWide, cellsHigh), mipmapLevel: 0, withBytes: seed, bytesPerRow: cellsWide * MemoryLayout<UInt8>.stride)
    }
    
    func currentGenerationTexture() -> MTLTexture {
        generation % 2 == 0 ? genA : genB
    }
    
    func nextGenerationTexture() -> MTLTexture {
        generation % 2 == 0 ? genB : genA
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard
            let buffer = commandQueue.makeCommandBuffer(),
            let desc = view.currentRenderPassDescriptor,
            let renderEncoder = buffer.makeRenderCommandEncoder(descriptor: desc)
        else { return }
        
        renderEncoder.setRenderPipelineState(renderState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(currentGenerationTexture(), index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        
        guard
            let computeEncoder = buffer.makeComputeCommandEncoder()
        else { return }
        computeEncoder.setComputePipelineState(computeState)
        computeEncoder.setTexture(currentGenerationTexture(), index: 0)
        computeEncoder.setTexture(nextGenerationTexture(), index: 1)
        let threadWidth = computeState.threadExecutionWidth
        let threadHeight = computeState.maxTotalThreadsPerThreadgroup / threadWidth
        let threadsPerThreadgroup = MTLSizeMake(threadWidth, threadHeight, 1)
        let threadsPerGrid = MTLSizeMake(cellsWide, cellsHigh, 1)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()
        
        if let drawable = view.currentDrawable {
            buffer.present(drawable)
        }
        buffer.commit()
        
        generation += 1
    }
}
