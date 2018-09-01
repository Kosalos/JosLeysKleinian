import UIKit
import Metal
import simd

var control = Control()
var boundsData = BoundsData()
var vc:ViewController! = nil

class ViewController: UIViewController, WGDelegate {
    var aData = ArcBallData()
    var tv:UITextView! = nil
    var cBuffer:MTLBuffer! = nil
    var bBuffer:MTLBuffer! = nil
    var outTextureL: MTLTexture!
    var outTextureR: MTLTexture!
    var pipeline1: MTLComputePipelineState!
    lazy var device: MTLDevice! = MTLCreateSystemDefaultDevice()
    lazy var commandQueue: MTLCommandQueue! = { return device.makeCommandQueue() }()
    var isStereo:Bool = false
    var isHighRes:Bool = false
    var isRotate:Bool = false
    var isMorph:Bool = false
    var showControl:Bool = false
    
    let threadGroupCount = MTLSizeMake(20,20, 1)
    var threadGroups = MTLSize()
    
    @IBOutlet var metalTextureViewL: MetalTextureView!
    @IBOutlet var metalTextureViewR: MetalTextureView!
    @IBOutlet var wg:WidgetGroup!
    @IBOutlet var cRotate: CRotate!
    @IBOutlet var cTranslate: CTranslate!
    @IBOutlet var cTranslateZ: CTranslateZ!
    @IBOutlet var parallax: Widget!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vc = self
        
        tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.text = ""
        tv.isHidden = true
        tv.isEditable = false
        tv.isSelectable = false
        tv.isUserInteractionEnabled = false
        view.addSubview(tv)
        view.bringSubview(toFront:tv)
        
        cBuffer = device.makeBuffer(bytes: &control, length: MemoryLayout<Control>.stride, options: MTLResourceOptions.storageModeShared)
        bBuffer = device.makeBuffer(bytes: &boundsData, length: MemoryLayout<BoundsData>.stride, options: MTLResourceOptions.storageModeShared)
        
        do {
            let defaultLibrary:MTLLibrary! = device.makeDefaultLibrary()
            guard let kf1 = defaultLibrary.makeFunction(name: "mandelBoxShader")  else { fatalError() }
            pipeline1 = try device.makeComputePipelineState(function: kf1)
        } catch { fatalError("error creating pipelines") }
        
        wg.initialize()
        wg.delegate = self
        initializeWidgetGroup()
        layoutViews()
        
        let parallaxRange:Float = 0.08
        parallax.initSingle(&control.parallax,  -parallaxRange,+parallaxRange,0.0002, "Parallax")
        parallax.highlight(0)
        
        for w in [ cTranslate,cTranslateZ,cRotate,parallax ] as [Any] { view.bringSubview(toFront:w as! UIView) }
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tap2Gesture(_:)))
        tap2.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap2)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeWgGesture(gesture:)))
        swipeUp.direction = .up
        wg.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeWgGesture(gesture:)))
        swipeDown.direction = .down
        wg.addGestureRecognizer(swipeDown)
        
        reset()
        Timer.scheduledTimer(withTimeInterval:0.05, repeats:true) { timer in self.timerHandler() }
    }
    
    @objc func tap2Gesture(_ sender: UITapGestureRecognizer) {
        wg.isHidden = !wg.isHidden
        layoutViews()
        updateImage()
    }
    
    @objc func swipeWgGesture(gesture: UISwipeGestureRecognizer) -> Void {
        switch gesture.direction {
        case .up : wg.moveFocus(-1)
        case .down : wg.moveFocus(+1)
        default : break
        }
    }
    
    //MARK: -
    
    func initializeWidgetGroup() {
        wg.reset()
        wg.addToggle(.resolution)
        wg.addLine()
        wg.addSingleFloat(&control.zoom,  0.2,2, 0.03, "Zoom")
        
        wg.addLine()
        wg.addSingleFloat(&control.fMaxSteps,10,300,10, "Max Steps")
        wg.addSingleFloat(&control.fFinal_Iterations, 1,50,1, "FinalIter")
        wg.addSingleFloat(&control.fBox_Iterations, 1,50,1, "BoxIter")
        wg.addLine()
        wg.addColoredCommand(.showBalls,"ShowBalls")
        wg.addColoredCommand(.doInversion,"DoInversion")
        wg.addColoredCommand(.fourGen,"FourGen")
        wg.addLine()
        wg.addSingleFloat(&control.Clamp_y, 0.001,2,0.1, "Clamp_y")
        wg.addSingleFloat(&control.Clamp_DF, 0.001,2,0.3, "Clamp_DF")
        wg.addSingleFloat(&control.box_size_x, 0.01,2,0.3, "box_size_x")
        wg.addSingleFloat(&control.box_size_z, 0.01,2,0.3, "box_size_z")
        wg.addLine()
        wg.addSingleFloat(&control.KleinR, 0.01,2.5,0.3, "KleinR")
        wg.addSingleFloat(&control.KleinI, 0.01,2.5,0.3, "KleinI")
        
        wg.addTriplet(&control.InvCenter,0,1.5,0.2,"InvCenter")
        
        wg.addSingleFloat(&control.DeltaAngle, 0.1,10,0.1, "DeltaAngle")
        wg.addSingleFloat(&control.InvRadius, 0.01,2,0.3, "InvRadius")
        wg.addSingleFloat(&control.deScale, 0.01,2,0.5, "DE Scale")
        
        wg.addSingleFloat(&control.epsilon, 0.00001, 0.05, 0.01, "epsilon")
        wg.addSingleFloat(&control.normalEpsilon, 0.00001, 0.04, 0.002, "N epsilon")
        wg.addLine()
        let sPmin:Float = 0.01
        let sPmax:Float = 1
        let sPchg:Float = 0.25
        wg.addSingleFloat(&control.lighting.diffuse,sPmin,sPmax,sPchg, "Bright")
        wg.addSingleFloat(&control.lighting.specular,sPmin,sPmax,sPchg, "Shiny")
        wg.addTriplet(&control.lighting.position,-10,10,3,"Light")
        wg.addTriplet(&control.color,0,0.5,0.2,"Tint")
        
        wg.addCommand("Save/Load",.saveLoad)
        wg.addCommand("Reset",.reset)
        wg.addColoredCommand(.stereo,"Stereo")
        wg.addColoredCommand(.rotate,"Rotate")
        wg.addColoredCommand(.morph,"Morph")
        wg.addCommand("Show Params",.controlDisplay)
        wg.addCommand("Help",.help)
    }
    
    //MARK: -
    
    func wgCommand(_ ident:WgIdent) {
        switch(ident) {
        case .controlDisplay :
            tv.isHidden = !tv.isHidden
            controlDisplay()
        case .saveLoad :
            saveLoadStyle = .settings
            performSegue(withIdentifier: "saveLoadSegue", sender: self)
        case .help :
            performSegue(withIdentifier: "helpSegue", sender: self)
        case .reset : reset()
        case .showBalls : control.showBalls = !control.showBalls; updateImage()
        case .doInversion : control.doInversion = !control.doInversion; updateImage()
        case .fourGen : control.fourGen = !control.fourGen; updateImage()
        case .stereo :
            isStereo = !isStereo
            layoutViews()
        case .rotate :
            isRotate = !isRotate
            initializeObjectCenterDataset()
        case .morph : isMorph = !isMorph
        default : break
        }
        
        wg.setNeedsDisplay()
    }
    
    func wgToggle(_ ident:WgIdent) {
        switch(ident) {
        case .resolution :
            isHighRes = !isHighRes
            setImageViewResolution()
            updateImage()
        case .stereo :
            isStereo = !isStereo
            layoutViews()
            updateImage()
        case .morph :
            isMorph = !isMorph
        case .rotate :
            isRotate = !isRotate
        default : break
        }
        
        wg.setNeedsDisplay()
    }
    
    func wgGetString(_ index: WgIdent) -> String {
        switch index {
        case .resolution :
            return isHighRes ? "Res: High" : "Res: Low"
        default : return ""
        }
    }
    
    func wgGetColor(_ index: WgIdent) -> UIColor {
        var highlight:Bool = false
        switch(index) {
        case .showBalls : highlight = control.showBalls
        case .doInversion : highlight = control.doInversion
        case .fourGen : highlight = control.fourGen
        case .stereo : highlight = isStereo
        case .rotate : highlight = isRotate
        case .morph : highlight = isMorph
        default : break
        }
        
        if highlight { return UIColor(red:0.2, green:0.2, blue:0, alpha:1) }
        return .black
    }
    
    func wgOptionSelected(_ ident: WgIdent, _ index: Int) {
        switch ident {
        default : break
        }
    }
    
    func wgGetOptionString(_ ident: WgIdent) -> String {
        switch ident {
        default : return "noOption"
        }
    }
    
    //MARK: -
    
    var rotateAngle = float2()
    var rotateDistance = float3()
    var rawAverageObjectCenter = float3()
    var smoothedAverageObjectCenter = float3()

    func initializeObjectCenterDataset() {
        smoothedAverageObjectCenter = rawAverageObjectCenter
        rotateAngle = float2()
        rotateDistance = control.camera * 2
    }
    
    func updateRotatePosition() {
        func rotatePos(_ old:float3, _ rX:Float, _ rY:Float) -> float3 {
            var pos = old
            
            if rX != 0 {    // X/Y rotation
                let ss = sinf(rX)
                let cc = cosf(rX)
                let qt = pos.x
                pos.x = pos.x * cc - pos.y * ss
                pos.y = qt * ss + pos.y * cc
            }
            
            if rY != 0 {    // X/Z rotation
                let ss = sinf(rY)
                let cc = cosf(rY)
                let qt = pos.x
                pos.x = pos.x * cc - pos.z * ss
                pos.z = qt * ss + pos.z * cc
            }
            
            return pos
        }

        // slowly move center towards latest calculated position
        smoothedAverageObjectCenter += (rawAverageObjectCenter - smoothedAverageObjectCenter) / 50
        
        control.camera = smoothedAverageObjectCenter - rotatePos(rotateDistance, rotateAngle.x, rotateAngle.y)
        control.focus  = smoothedAverageObjectCenter
        
        rotateAngle += float2(0.01,0.013)
    }
    
    //MARK: -
    
    var morphAngle:Float = 0
    
    func updateMorph() {
        let s = sin(morphAngle) * 0.003
        morphAngle += 0.01
        
        for i in 0 ..< wg.data.count {
            wg.morph(i,s)
        }
    }
    
    //MARK: -
    
    @objc func timerHandler() {
        var refresh:Bool = false
        if cTranslate.update() { refresh = true }
        if cTranslateZ.update() { refresh = true }
        if cRotate.update() { refresh = true }
        if parallax.update() { refresh = true }
        if wg.update() { refresh = true }
        
        if isRotate {
            refresh = true
            updateRotatePosition()
        }
        
        if isMorph {
            refresh = true
            updateMorph()
        }
        
        if refresh && !isBusy {
            if !tv.isHidden { controlDisplay() }
            updateImage()
        }
    }
    
    //MARK: -
    
    func reset() {
        isHighRes = false
        
        control.camera = vector_float3(-0.168532, 1.38868, -1.42637)
        control.focus = vector_float3(-0.168515, 1.36687, -1.3299)
        
        control.zoom = 0.6141
        control.epsilon = 0.00166499999
        control.normalEpsilon = 0.000232000006
        
        control.lighting.position = float3(-10.0, 0.6645, 1.6055)
        control.lighting.diffuse = 0.653
        control.lighting.specular = 0.820
        
        control.color = float3(0.7)
        control.parallax = 0.0011
        control.fog = 180         // max distance
        
        control.fMaxSteps = 70
        control.fFinal_Iterations = 21
        control.fBox_Iterations = 17
        
        control.showBalls = false
        control.doInversion = true
        control.fourGen = false
        control.Clamp_y = 0.221299887
        control.Clamp_DF = 0.00999999977
        control.box_size_z = 1.98095
        control.box_size_x = 0.934900045
        control.KleinR = 1.9324
        control.KleinI = 0.04583
        
        control.InvCenter = float3(0.0, 1.0294, 0.1879)
        control.ReCenter = float3(0.0, 0.0, 0.1468)
        control.DeltaAngle = 5.5392437
        control.InvRadius = 0.496100187
        control.deScale = 0.565749943
        
        aData.endPosition = simd_float3x3([-0.713134, -0.670681, -0.147344], [0.000170747, -0.218116, 0.964759], [-0.683193, 0.68709, 0.152579])
        aData.transformMatrix = simd_float4x4([-0.713134, -0.670681, -0.147344, 0.0], [0.000170747, -0.218116, 0.964759, 0.0], [-0.683193, 0.68709, 0.152579, 0.0], [0.0, 0.0, 0.0, 1.0])
        
        alterAngle(0,0)
        updateImage()
    }
    
    //MARK: -
    
    func controlJustLoaded() {
        aData = control.aData
        isHighRes = false
        wg.setNeedsDisplay()
        setImageViewResolution()
        updateImage()
    }
    
    func setImageViewResolution() {
        control.xSize = Int32(metalTextureViewL.frame.width)
        control.ySize = Int32(metalTextureViewL.frame.height)
        if !isHighRes {
            control.xSize /= 2
            control.ySize /= 2
        }
        
        let xsz = Int(control.xSize)
        let ysz = Int(control.ySize)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm_srgb,
            width: xsz,
            height: ysz,
            mipmapped: false)
        
        outTextureL = self.device.makeTexture(descriptor: textureDescriptor)!
        outTextureR = self.device.makeTexture(descriptor: textureDescriptor)!
        
        metalTextureViewL.initialize(outTextureL)
        metalTextureViewR.initialize(outTextureR)
        
        let maxsz = max(xsz,ysz) + Int(threadGroupCount.width-1)
        threadGroups = MTLSizeMake(
            maxsz / threadGroupCount.width,
            maxsz / threadGroupCount.height,1)
    }
    
    //MARK: -
    
    func removeAllFocus() {
        if cTranslate.hasFocus { cTranslate.hasFocus = false; cTranslate.setNeedsDisplay() }
        if cTranslateZ.hasFocus { cTranslateZ.hasFocus = false; cTranslateZ.setNeedsDisplay() }
        if cRotate.hasFocus { cRotate.hasFocus = false; cRotate.setNeedsDisplay() }
        if parallax.hasFocus { parallax.hasFocus = false; parallax.setNeedsDisplay() }        
        if wg.hasFocus() { wg.removeAllFocus() }
    }
    
    func focusMovement(_ pt:CGPoint, _ touchCount:Int = 0) {
        if wg.hasFocus() { wg.focusMovement(pt,touchCount); return }
        if cTranslate.hasFocus { cTranslate.focusMovement(pt); return }
        if cTranslateZ.hasFocus { cTranslateZ.focusMovement(pt); return }
        if cRotate.hasFocus { cRotate.focusMovement(pt); return }
        if parallax.hasFocus { parallax.focusMovement(pt) }
    }
    
    //MARK: -
    
    @objc func layoutViews() {
        var xBase = CGFloat()
        let xs = view.bounds.width
        let ys = view.bounds.height
        
        if !wg.isHidden {
            xBase = 160
            wg.frame = CGRect(x:0, y:0, width:xBase, height:ys)
        }
        
        if isStereo {
            metalTextureViewR.isHidden = false
            parallax.isHidden = false
            
            let xs2:CGFloat = (xs - xBase)/2
            metalTextureViewL.frame = CGRect(x:xBase, y:0, width:xs2, height:ys)
            metalTextureViewR.frame = CGRect(x:xBase+xs2+1, y:0, width:xs2, height:ys) // +1 = 1 pixel of bkground between
        }
        else {
            metalTextureViewR.isHidden = true
            parallax.isHidden = true
            metalTextureViewL.frame = CGRect(x:xBase, y:0, width:xs-xBase, height:ys)
        }
        
        // --------------------------------------------
        var x:CGFloat = xBase + 10
        var y:CGFloat = ys - 100
        
        func frame(_ xs:CGFloat, _ ys:CGFloat, _ dx:CGFloat, _ dy:CGFloat) -> CGRect {
            let r = CGRect(x:x, y:y, width:xs, height:ys)
            x += dx; y += dy
            return r
        }
        
        cTranslate.frame = frame(80,80,90,0)
        cTranslateZ.frame = frame(30,80,40,45)
        parallax.frame = frame(80,35,0,0)
        x = xs - 90
        y = ys - 100
        cRotate.frame = frame(80,80,0,0)
        
        tv.frame = CGRect(x:xBase+10, y:1, width:800, height:760)
        
        arcBall.initialize(Float(cRotate.frame.width),Float(cRotate.frame.height))
        setImageViewResolution()
        updateImage()
    }
    
    //MARK: -
    
    func alterAngle(_ dx:Float, _ dy:Float) {
        if isRotate {
            let amt:Float = dx > 0 ? 0.95 : 1.05
            rotateDistance *= amt
            return
        }
        
        let center:CGFloat = cRotate.bounds.width/2
        arcBall.mouseDown(CGPoint(x: center, y: center))
        arcBall.mouseMove(CGPoint(x: center + CGFloat(dx/50), y: center + CGFloat(dy/50)))
        
        let direction = simd_make_float4(0,0.1,0,0)
        let rotatedDirection = simd_mul(aData.transformMatrix, direction)
        
        control.focus.x = rotatedDirection.x
        control.focus.y = rotatedDirection.y
        control.focus.z = rotatedDirection.z
        control.focus += control.camera
        
        updateImage()
    }
    
    func alterPosition(_ dx:Float, _ dy:Float, _ dz:Float) {
        func axisAlter(_ dir:float4, _ amt:Float) {
            let diff = simd_mul(aData.transformMatrix, dir) * amt / 300.0
            
            func alter(_ value: inout float3) {
                value.x -= diff.x
                value.y -= diff.y
                value.z -= diff.z
            }
            
            alter(&control.camera)
            alter(&control.focus)
        }
        
        if isRotate {
            smoothedAverageObjectCenter.x += dx / 500
            smoothedAverageObjectCenter.y += dy / 500
            smoothedAverageObjectCenter.z += dz / 500
            return
        }
        
        let q:Float = 0.1
        axisAlter(simd_make_float4(q,0,0,0),dx)
        axisAlter(simd_make_float4(0,0,q,0),dy)
        axisAlter(simd_make_float4(0,q,0,0),dz)
        
        updateImage()
    }
    
    //MARK: -
    
    var isBusy:Bool = false
    
    func updateImage() {
        if isBusy { return }
        isBusy = true
        
        func toRectangular(_ sph:float3) -> float3 {
            let ss = sph.x * sin(sph.z);
            return float3( ss * cos(sph.y), ss * sin(sph.y), sph.x * cos(sph.z));
        }
        
        func toSpherical(_ rec:float3) -> float3 {
            return float3(length(rec),
                          atan2(rec.y,rec.x),
                          atan2(sqrt(rec.x*rec.x+rec.y*rec.y), rec.z));
        }
        
        control.viewVector = control.focus - control.camera
        control.topVector = toSpherical(control.viewVector)
        control.topVector.z += 1.5708
        control.topVector = toRectangular(control.topVector)
        control.sideVector = cross(control.viewVector,control.topVector)
        control.sideVector = normalize(control.sideVector) * length(control.topVector)
        
        control.Final_Iterations = Int32(control.fFinal_Iterations)
        control.Box_Iterations = Int32(control.fBox_Iterations)
        control.maxSteps = Int32(control.fMaxSteps);
        
        calcRayMarch(0)
        metalTextureViewL.display(metalTextureViewL.layer)
        
        if isStereo {
            calcRayMarch(1)
            metalTextureViewR.display(metalTextureViewR.layer)
        }
        
        // update objects' average position
        memcpy(&boundsData,bBuffer.contents(),MemoryLayout<BoundsData>.stride)
        rawAverageObjectCenter = boundsData.position / Float(boundsData.count)
        
        isBusy = false
    }
    
    //MARK: -
    
    func calcRayMarch(_ who:Int) {
        var c = control
        if who == 0 { c.camera.x -= control.parallax }
        if who == 1 { c.camera.x += control.parallax }
        c.lighting.position = normalize(c.lighting.position)
        
        cBuffer.contents().copyMemory(from: &c, byteCount:MemoryLayout<Control>.stride)
        
        boundsData.position = float3()  // reset object's position accumulator fields
        boundsData.count = 0
        bBuffer.contents().copyMemory(from: &boundsData, byteCount:MemoryLayout<BoundsData>.stride)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        commandEncoder.setComputePipelineState(pipeline1)
        commandEncoder.setTexture(who == 0 ? outTextureL : outTextureR, index: 0)
        commandEncoder.setBuffer(cBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(bBuffer, offset: 0, index: 1)
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
