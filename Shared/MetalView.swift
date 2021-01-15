//
//  MetalView.swift
//  LifeLab
//
//  Created by Jonathan Attfield on 08/01/2021.
//

import MetalKit

class MetalView : MTKView {
    var renderer : Renderer!
    var cameraController : CameraController!
    
    init() {
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let defaultDevice = device else {
            fatalError("Device loading error")
        }
        colorPixelFormat = .bgra8Unorm_srgb
        clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1)
        depthStencilPixelFormat = .depth32Float
        sampleCount = 4
        createRenderer(device: defaultDevice)
        cameraController = CameraController()
        renderer.viewMatrix = cameraController.viewMatrix
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    func createRenderer(device: MTLDevice) {
        renderer = Renderer(view: self, device: device)
        delegate = renderer
    }
}
