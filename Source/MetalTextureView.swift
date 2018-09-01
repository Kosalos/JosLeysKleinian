import UIKit
import Metal
import MetalKit

class MetalTextureView: MTKView,MTKViewDelegate {
    var pipelineR: MTLRenderPipelineState!
    var sampler: MTLSamplerState?
    var vertices: MTLBuffer?
    var outTexture: MTLTexture! = nil
    let queue = DispatchQueue(label:"Q")
    var commandQueue: MTLCommandQueue! = nil

    func initialize(_ texture:MTLTexture) {
        delegate = self
        outTexture = texture

        let device:MTLDevice! = MTLCreateSystemDefaultDevice()
        self.device = device
        commandQueue = device.makeCommandQueue()

        do {
            let library: MTLLibrary = try device.makeDefaultLibrary(bundle: .main)
            let descriptor: MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction   = library.makeFunction(name: "metalTextureView_Vertex")
            descriptor.fragmentFunction = library.makeFunction(name: "metalTextureView_Fragment")
            descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
            pipelineR = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(String(describing: error))
        }
        
        let p1 = float2(0,0)
        let p2 = float2(1,0)
        let p3 = float2(0,1)
        let p4 = float2(1,1)
        vertices = device.makeBuffer(bytes: [p1,p2,p3,p4], length: 4 * MemoryLayout<float2>.stride,  options: [])

        let descriptor: MTLSamplerDescriptor = MTLSamplerDescriptor()
        descriptor.magFilter = .nearest
        descriptor.minFilter = .nearest
        descriptor.sAddressMode = .repeat
        descriptor.tAddressMode = .repeat
        sampler = device.makeSamplerState(descriptor: descriptor)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        addGestureRecognizer(pan)
    }
    
    //MARK: -
    
    func draw(in view: MTKView) {
        if outTexture == nil { Swift.print("Must call MetalTextureView.initialize() first!"); exit(0) }
        
        let descriptor:MTLRenderPassDescriptor = currentRenderPassDescriptor!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        guard let encoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
        encoder.setRenderPipelineState(pipelineR)
        encoder.setVertexBuffer(vertices, offset: 0, index: 0)
        encoder.setFragmentTexture(outTexture, index: 0)
        encoder.setFragmentSamplerState(sampler, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()
        
        if let drawable = currentDrawable { commandBuffer.present(drawable) }
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    //MARK: -

    var pt = CGPoint()
    
    @objc func panGesture(_ sender: UITapGestureRecognizer) {
        var npt = sender.location(in: self)
        
        switch sender.state {
        case .began :
            pt = npt
        case .changed :
            npt.x -= pt.x
            npt.y -= pt.y
            vc.focusMovement(npt, sender.numberOfTouches)
        case .ended :
            pt.x = 0
            pt.y = 0
            vc.focusMovement(pt)
        default : break
        }
    }
}
