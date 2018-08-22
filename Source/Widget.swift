import UIKit

enum CommonWidgetKind { case rotate,translate,translateZ,widget }
enum WidgetKind { case single,dual }

let limitColor    = UIColor(red:0.25, green:0.25, blue:0.2, alpha: 1)
let fastEditColor = UIColor(red:0.2,  green:0.2,  blue:0.2, alpha: 1)
let slowEditColor = UIColor(red:0.4,  green:0.2,  blue:0.2, alpha: 1)
let textColor = UIColor.lightGray

class CommonWidget: UIView {
    let UNUSED:CGFloat = 9999
    var context : CGContext?
    var widgetKind:CommonWidgetKind = .widget
    var kind:WidgetKind = .single
    var ident:Int = 0
    var dx:Float = 0
    var dy:Float = 0
    var deltaValue:Float = 0
    var name:String = "name"
    var mRange = float2()
    var touched = false
    var fastEdit = true
    var hasFocus = false
    lazy var highLightPoint = CGPoint(x:UNUSED,y:UNUSED)
    var valuePointerX:UnsafeMutableRawPointer! = nil
    var valuePointerY:UnsafeMutableRawPointer! = nil
    let viewSize:Float = 4  // -2 ... +2
    var scale:Float = 0
    var xc:CGFloat = 0
    
    func tapCommon() {
        dx = 0
        dy = 0
        setNeedsDisplay()
    }
    
    //MARK:-
    
    func focusMovement(_ pt:CGPoint) {
        if pt.x == 0 { touched = false; return }
        
        switch widgetKind {
        case .rotate :
            dx =  Float(pt.x) / 6
            dy = -Float(pt.y) / 6
            
            if !fastEdit {
                dx /= 10
                dy /= 10
            }
        case .translate :
            dx = Float(pt.x) / 2
            dy = Float(pt.y) / 2
            
            if !fastEdit {
                dx /= 10
                dy /= 10
            }
        case .translateZ :
            dy = Float(pt.y) / 2
            
            if !fastEdit {
                dy /= 10
            }
        case .widget :
            dx =  Float(pt.x) / 300
            dy = -Float(pt.y) / 300
            
            if !fastEdit {
                dx /= 30
                dy /= 30
            }
        }
        
        touched = true
        setNeedsDisplay()
    }
    
    //MARK:-
    
    func firstDraw() {
        if scale == 0 {
            scale = viewSize / Float(bounds.width)
            xc = bounds.width / 2
            
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap1(_:)))
            tap1.numberOfTapsRequired = 1
            addGestureRecognizer(tap1)
            
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))
            tap2.numberOfTapsRequired = 2
            addGestureRecognizer(tap2)
            
            isUserInteractionEnabled = true
            self.backgroundColor = .clear
        }
    }
    
    func commonDraw1() {
        firstDraw()
        
        context = UIGraphicsGetCurrentContext()
        context?.setFillColor(fastEdit ? fastEditColor.cgColor : slowEditColor.cgColor)
        context?.addRect(bounds)
        context?.fillPath()
        
        UIColor.black.set()
        context?.setLineWidth(2)
    }
    
    func commonDraw2() {
        drawBorder(context!,bounds)
        
        if hasFocus {
            context?.setLineWidth(1)
            context!.setStrokeColor(UIColor.red.cgColor)
            drawRect(context!,bounds)
        }
    }
    
    @objc func handleTap1(_ sender: UITapGestureRecognizer) {
        vc.removeAllFocus()
        hasFocus = true
        tapCommon()
    }
    
    @objc func handleTap2(_ sender: UITapGestureRecognizer) {
        fastEdit = !fastEdit
        tapCommon()
    }
    
    //MARK:-
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let pt = touch.location(in: self)
            dx = Float(pt.x - bounds.size.width/2) * 0.05
            dy = Float(pt.y - bounds.size.height/2) * 0.05
            touched = true
            
            if !fastEdit {
                dx /= 10
                dy /= 10
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { touchesBegan(touches, with:event) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { touched = false }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { touchesEnded(touches, with:event) }
}

//MARK:-

class Widget: CommonWidget {
    
    func initCommon(_ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        mRange.x = min
        mRange.y = max
        deltaValue = delta
        name = iname
    }
    
    func initSingle(_ vx:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        kind = .single
        valuePointerX = vx
        initCommon(min,max,delta,iname)
    }
    
    func initDual(_ vx:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        kind = .dual
        valuePointerX = vx
        initCommon(min,max,delta,iname)
    }
    func initDual2(_ vy:UnsafeMutableRawPointer) { valuePointerY = vy }
    
    //MARK:-
    
    func highlight(_ x:CGFloat, _ y:CGFloat) {
        highLightPoint.x = x
        highLightPoint.y = y
    }
    
    func highlight(_ x:CGFloat) {
        highLightPoint.x = x
    }
    
    func percentX(_ percent:CGFloat) -> CGFloat { return CGFloat(bounds.size.width) * percent }
    
    //MARK:-
    
    override func draw(_ rect: CGRect) {
        firstDraw()
        
        context = UIGraphicsGetCurrentContext()
        
        if fastEdit { fastEditColor.set() } else { slowEditColor.set() }
        UIBezierPath(rect:bounds).fill()
        
        if isMinValue(0) {  // X coord
            limitColor.set()
            var r = bounds
            r.size.width /= 2
            UIBezierPath(rect:r).fill()
        }
        else if isMaxValue(0) {
            limitColor.set()
            var r = bounds
            r.origin.x += bounds.width/2
            r.size.width /= 2
            UIBezierPath(rect:r).fill()
        }
        
        if kind == .dual {
            if isMaxValue(1) {  // Y coord
                limitColor.set()
                var r = bounds
                r.size.height /= 2
                UIBezierPath(rect:r).fill()
            }
            else if isMinValue(1) {
                limitColor.set()
                var r = bounds
                r.origin.y += bounds.width/2
                r.size.height /= 2
                UIBezierPath(rect:r).fill()
            }
        }
        
        UIColor.black.set()
        context?.setLineWidth(2)
        drawVLine(context!,bounds.midX,0,bounds.height)
        
        let cursorX = valueRatio(0) * bounds.width
        
        if kind == .dual {
            drawHLine(context!,0,bounds.width,bounds.midY)
            
            let y = (CGFloat(1) - valueRatio(1)) * bounds.height
            drawFilledCircle(context!,CGPoint(x:cursorX,y:y),15,UIColor.black.cgColor)
        }
        else {
            UIColor.darkGray.set()
            drawVLine(context!,cursorX,0,bounds.height)
        }
        
        drawText(10,8,textColor,16,name)
        
        if highLightPoint.x != UNUSED {
            let den = CGFloat(mRange.y - mRange.x)
            if den != 0 {
                let vx:CGFloat = (highLightPoint.x - CGFloat(mRange.x)) / den
                let vy:CGFloat = (highLightPoint.y - CGFloat(mRange.x)) / den
                let x = CGFloat(vx) * bounds.width
                let y = (kind == .dual) ? (CGFloat(1) - vy) * bounds.height : bounds.midY
                
                drawFilledCircle(context!,CGPoint(x:x,y:y),4,UIColor.darkGray.cgColor)
            }
        }
        
        commonDraw2()
    }
    
    func fClamp2(_ v:Float, _ range:float2) -> Float {
        if v < range.x { return range.x }
        if v > range.y { return range.y }
        return v
    }
    
    //MARK:-
    
    func getValue(_ who:Int) -> Float {
        switch who {
        case 0 :
            if valuePointerX == nil { return 0 }
            return valuePointerX.load(as: Float.self)
        default:
            if valuePointerY == nil { return 0 }
            return valuePointerY.load(as: Float.self)
        }
    }
    
    func isMinValue(_ who:Int) -> Bool {
        if valuePointerX == nil { return false }
        return getValue(who) == mRange.x
    }
    
    func isMaxValue(_ who:Int) -> Bool {
        if valuePointerX == nil { return false }
        return getValue(who) == mRange.y
    }
    
    func valueRatio(_ who:Int) -> CGFloat {
        let den = mRange.y - mRange.x
        if den == 0 { return CGFloat(0) }
        return CGFloat((getValue(who) - mRange.x) / den )
    }
    
    //MARK:-
    
    func update() -> Bool {
        if valuePointerX == nil || !touched { return false }
        
        let valueX = fClamp2(getValue(0) + dx * deltaValue, mRange)
        let valueY = fClamp2(getValue(1) + dy * deltaValue, mRange)
        
        if let valuePointerX = valuePointerX { valuePointerX.storeBytes(of:valueX, as:Float.self) }
        if let valuePointerY = valuePointerY { valuePointerY.storeBytes(of:valueY, as:Float.self) }
        
        setNeedsDisplay()
        return true
    }
}

//MARK:-

class CRotate: CommonWidget {
    override func draw(_ rect: CGRect) {
        widgetKind = .rotate
        commonDraw1()
        
        drawVLine(context!,bounds.midX,0,bounds.height)
        drawHLine(context!,0,bounds.width,bounds.midY)
        drawText(10,8,textColor,16,"Rotate")
        
        commonDraw2()
    }
    
    func update() -> Bool {
        if touched { vc.alterAngle(dx,dy) }
        return touched
    }
}

//MARK:-

class CTranslate: CommonWidget {
    override func draw(_ rect: CGRect) {
        widgetKind = .translate
        commonDraw1()
        
        drawVLine(context!,bounds.midX,0,bounds.height)
        drawHLine(context!,0,bounds.width,bounds.midY)
        drawText(10,8,textColor,16,"Move")
        
        commonDraw2()
    }
    
    func update() -> Bool {
        if touched { vc.alterPosition(dx,dy,0) }
        return touched
    }
}

//MARK:-

class CTranslateZ: CommonWidget {
    override func draw(_ rect: CGRect) {
        widgetKind = .translateZ
        commonDraw1()
        
        drawHLine(context!,0,bounds.width,bounds.midY)
        
        commonDraw2()
    }
    
    func update() -> Bool {
        if touched { vc.alterPosition(0,0,dy) }
        return touched
    }
}

//MARK:-

func drawBorder(_ context:CGContext,_ rect:CGRect) {
    let colorGray1 = UIColor(red:0.01, green:0.01, blue:0.01, alpha:1).cgColor
    let colorGray3 = UIColor(red:0.4, green:0.4, blue:0.4, alpha:1).cgColor
    let p1  = CGPoint(x:rect.minX, y:rect.minY)
    let p2  = CGPoint(x:rect.minX + rect.width, y:rect.minY)
    let p3  = CGPoint(x:rect.minX + rect.width, y:rect.minY + rect.height)
    let p4  = CGPoint(x:rect.minX, y:rect.minY + rect.height)
    
    func line(_ p1:CGPoint, _ p2:CGPoint, _ strokeColor:CGColor) {
        let path = CGMutablePath()
        path.move(to: p1)
        path.addLine(to: p2)
        
        context.setLineWidth(3)
        context.beginPath()
        context.setStrokeColor(strokeColor)
        context.addPath(path)
        context.drawPath(using:.stroke)
    }
    
    line(p1,p2,colorGray1)
    line(p1,p4,colorGray1)
    line(p2,p3,colorGray3)
    line(p3,p4,colorGray3)
}

