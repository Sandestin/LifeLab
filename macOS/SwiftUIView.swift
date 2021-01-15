//
//  SwiftUIView.swift
//  LifeLab (macOS)
//
//  Created by Jonathan Attfield on 08/01/2021.
//

import SwiftUI
import MetalKit

public struct SwiftUIView : NSViewRepresentable {
    public typealias NSViewType = MTKView
    
    public var wrappedView : NSViewType
    private var handleUpdateUIView : ((NSViewType, Context) -> Void)?
    private var handleMakeUIView : ((Context) -> NSViewType)?
    
    public init(closure: () -> NSViewType) {
        wrappedView = closure()
    }
    
    public func makeUIView(context: Context) -> NSView {
        guard let handler = handleMakeUIView else {
            return wrappedView
        }
        return handler(context)
    }
    
    public func updateUIView(_ uiView: NSViewType, context: Context) {
        handleUpdateUIView?(uiView, context)
    }
    
    public func makeNSView(context: Context) -> MTKView {
        guard let handler = handleMakeUIView else {
            return wrappedView
        }
        return handler(context)
    }
    
    public func updateNSView(_ nsView: MTKView, context: Context) {
        handleUpdateUIView?(nsView, context)
    }
}

public extension SwiftUIView {
    mutating func setMakeUIView(handler: @escaping (Context) -> NSViewType) -> Self {
        handleMakeUIView = handler
        return self
    }
    
    mutating func setUpdateUIView(handler: @escaping (NSViewType, Context) -> Void) -> Self {
        handleUpdateUIView = handler
        return self
    }
}

extension MetalView {
    override func mouseDown(with event: NSEvent) {
        var point = convert(event.locationInWindow, from: nil)
        point.y = bounds.size.height - point.y
        //cameraController.startedInteraction(at: point)
    }
    
    override func mouseDragged(with event: NSEvent) {
        var point = convert(event.locationInWindow, from: nil)
        point.y = bounds.size.height - point.y
        //cameraController.dragged(to.point)
        //renderer.viewMatrix = cameraController.viewMatrix
    }
}
