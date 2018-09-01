import UIKit

protocol WGDelegate {
    func wgCommand(_ ident:WgIdent)
    func wgToggle(_ ident:WgIdent)
    func wgGetString(_ ident:WgIdent) -> String
    func wgGetColor(_ ident:WgIdent) -> UIColor
    func wgOptionSelected(_ ident:WgIdent, _ index:Int)
    func wgGetOptionString(_ ident:WgIdent) -> String
}

enum WgEntryKind { case singleFloat,dualFloat,dropDown,option,command,toggle,legend,line,string,color,move,gap,float3Dual,float3Single }
enum WgIdent { case none,resolution,morph,rotate,stereo,showBalls,doInversion,fourGen,saveLoad,reset,controlDisplay,help }

let NONE:Int = -1
let FontSZ:CGFloat = 20
let RowHT:CGFloat = 23
let GrphSZ:CGFloat = RowHT - 4
let TxtYoff:CGFloat = -3
let Tab1:CGFloat = 5     // graph x1
let Tab2:CGFloat = 24    // text after graph
let Tab3:CGFloat = Tab2 + GrphSZ + 3 // text after 2 graphs
var py = CGFloat()

struct wgEntryData {
    var kind:WgEntryKind = .legend
    var ident:WgIdent = .none
    var str:[String] = []
    var valuePointerX:UnsafeMutableRawPointer! = nil
    var valuePointerY:UnsafeMutableRawPointer! = nil
    var deltaValue:Float = 0
    var mRange = float2()
    var fastEdit:Bool = true
    var visible:Bool = true
    var yCoord = CGFloat()
    
    func isValueWidget() ->Bool { return kind == .singleFloat || kind == .dualFloat }
    
    func getFloatValue(_ who:Int) -> Float {
        switch who {
        case 0 :
            if valuePointerX == nil { return 0 }
            return valuePointerX.load(as: Float.self)
        default:
            if valuePointerY == nil { return 0 }
            return valuePointerY.load(as: Float.self)
        }
    }
    
    func getInt32Value() -> Int {
        if valuePointerX == nil { return 0 }
        let v =  Int(valuePointerX.load(as: Int32.self))
        //Swift.print("getInt32Value = ",v.description)
        return v;
    }
    
    func ratioClamped(_ v:CGFloat) -> CGFloat {
        if v < 0.05 { return CGFloat(0.05) }          // so graph line is always visible
        if v > 0.95 { return CGFloat(0.95) }
        return v
    }
    
    func valueRatio(_ who:Int) -> CGFloat {
        let den = mRange.y - mRange.x
        if den == 0 { return CGFloat(0) }
        return ratioClamped(CGFloat((getFloatValue(who) - mRange.x) / den ))
    }
    
    func float3ValueRatio(_ who:Int) -> CGFloat {
        func getFloat3Value(_ who:Int) -> Float {
            if valuePointerX == nil { return 0 }
            let v:float3 = valuePointerX.load(as: float3.self)
            switch who {
            case 0 : return v.x
            case 1 : return v.y
            case 2 : return v.z
            default: return 0
            }
        }
        
        let den = mRange.y - mRange.x
        if den == 0 { return CGFloat(0) }
        return ratioClamped(CGFloat((getFloat3Value(who) - mRange.x) / den ))
    }
}

class WidgetGroup: UIView {
    var delegate:WGDelegate?
    var context : CGContext?
    var data:[wgEntryData] = []
    var focus:Int = NONE
    var previousFocus:Int = NONE
    var delta = float3()
    let color = UIColor.lightGray
    
    func initialize() {
        self.backgroundColor = UIColor.black
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))
        tap2.numberOfTapsRequired = 2
        addGestureRecognizer(tap2)
    }
    
    @objc func handleTap2(_ sender: UITapGestureRecognizer) {
        if focus != NONE {
            data[focus].fastEdit = !data[focus].fastEdit
            
            if data[focus].kind == .float3Dual { data[focus+1].fastEdit = !data[focus+1].fastEdit } // companion .z portion of float3()
            
            setNeedsDisplay()
        }
    }
    
    func reset() { data.removeAll() }
    func hasFocus() -> Bool { return focus != NONE }
    func removeAllFocus() { focus = NONE; setNeedsDisplay() }
    
    func wgOptionSelected(_ ident:WgIdent, _ index:Int) {
        delegate?.wgOptionSelected(ident,index)
        setNeedsDisplay()
    }
    
    func morph(_ index:Int, _ amt:Float) {
        func morphFloat3Value() -> float3 { return data[index].valuePointerX.load(as: float3.self) }

        if data[index].fastEdit { return }
        
        switch(data[index].kind) {
        case .singleFloat :
            let valueX = fClamp2(data[index].getFloatValue(0) + amt, data[index].mRange)
            data[index].valuePointerX.storeBytes(of:valueX, as:Float.self)
            
            if data[index].kind == .dualFloat {
                let valueY = fClamp2(data[index].getFloatValue(1) + amt, data[index].mRange)
                data[index].valuePointerY.storeBytes(of:valueY, as:Float.self)
            }
            
        case .float3Dual :  // alter all fields of float3
            var v:float3 = morphFloat3Value()
            v.x = fClamp2(v.x + amt, data[index].mRange)
            v.y = fClamp2(v.y + amt, data[index].mRange)
            v.z = fClamp2(v.z + amt, data[index].mRange)
            data[index].valuePointerX.storeBytes(of:v, as:float3.self)
        default : break
        }
    }
    
    //MARK:-
    
    var dIndex:Int = 0
    
    func newEntry(_ nKind:WgEntryKind) {
        data.append(wgEntryData())
        dIndex = data.count-1
        
        data[dIndex].kind = nKind
    }
    
    func addCommon(_ ddIndex:Int, _ min:Float, _ max:Float, _ delta:Float, _ iname:String) {
        data[ddIndex].mRange.x = min
        data[ddIndex].mRange.y = max
        data[ddIndex].deltaValue = delta
        data[ddIndex].str.append(iname)
    }
    
    func addSingleFloat(_ vx:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        newEntry(.singleFloat)
        data[dIndex].valuePointerX = vx
        addCommon(dIndex,min,max,delta,iname)
    }
    
    func addDualFloat(_ vx:UnsafeMutableRawPointer, _ vy:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        newEntry(.dualFloat)
        data[dIndex].valuePointerX = vx
        data[dIndex].valuePointerY = vy
        addCommon(dIndex,min,max,delta,iname)
    }

    //MARK:-
    
    func addFloat3Dual(_ vx:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        newEntry(.float3Dual)
        data[dIndex].valuePointerX = vx
        addCommon(dIndex,min,max,delta,iname)
    }

    func addFloat3Single(_ vx:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        newEntry(.float3Single)
        data[dIndex].valuePointerX = vx
        addCommon(dIndex,min,max,delta,iname)
    }

    func addTriplet(_ vx:UnsafeMutableRawPointer, _ min:Float, _ max:Float,  _ delta:Float, _ iname:String) {
        addFloat3Dual  (vx, min,max,delta, iname)
        addFloat3Single(vx, min,max,delta, "")
        addLine()
    }

    //MARK:-

    func addDropDown(_ vx:UnsafeMutableRawPointer, _ items:[String]) {
        newEntry(.dropDown)
        data[dIndex].valuePointerX = vx
        for i in items { data[dIndex].str.append(i) }
    }
    
    func addLegend(_ iname:String) {
        newEntry(.legend)
        data[dIndex].str.append(iname)
    }
    
    func addToggle(_ ident:WgIdent) {
        newEntry(.toggle)
        data[dIndex].ident = ident
    }
    
    func addLine() {
        newEntry(.line)
    }
    
    func addMove() {
        newEntry(.move)
        data[dIndex].str.append("Move")
    }
    
    func addCommand(_ iname:String, _ ident:WgIdent) {
        newEntry(.command)
        data[dIndex].str.append(iname)
        data[dIndex].ident = ident
    }
    
    func addColoredCommand(_ nCmd:WgIdent, _ legend:String) {
        addColor(nCmd,Float(RowHT))
        addCommand(legend,nCmd)
    }
    
    func addString(_ iname:String, _ cNumber:WgIdent) {
        newEntry(.string)
        data[dIndex].str.append(iname)
        data[dIndex].ident = cNumber
    }
    
    func addColor(_ index:WgIdent, _ height:Float) {
        newEntry(.color)
        data[dIndex].ident = index
        data[dIndex].deltaValue = height
    }
    
    func addOptionSelect(_ ident:WgIdent, _ title:String, _ message:String, _ options:[String]) {
        newEntry(.option)
        data[dIndex].ident = ident
        data[dIndex].str.append(title)
        data[dIndex].str.append(message)
        for i in 0 ..< options.count { data[dIndex].str.append(options[i]) }
    }
    
    func addGap(_ height:Float) {
        newEntry(.gap)
        data[dIndex].deltaValue = height
    }
    
    //MARK:-
    
    func drawGraph(_ index:Int) {
        let d = data[index]
        let x:CGFloat = d.kind == .float3Single ? 8 + GrphSZ : 5
        let rect = CGRect(x:x, y:py, width:GrphSZ, height:GrphSZ)
        
        if d.fastEdit { UIColor.black.set() } else { UIColor.red.set() }
        UIBezierPath(rect:rect).fill()
        
        if d.kind != .move {       // x,y cursor lines
            context!.setLineWidth(2)
            color.set()
            
            switch d.kind {
            case .float3Dual :
                let cx = rect.origin.x + d.float3ValueRatio(0) * rect.width
                drawVLine(context!,cx,rect.origin.y,rect.origin.y + GrphSZ)
                
                let y = rect.origin.y + (1.0 - d.float3ValueRatio(1)) * rect.height
                drawHLine(context!,rect.origin.x,rect.origin.x + GrphSZ,y)
            case .float3Single :
                let cx = rect.origin.x + d.float3ValueRatio(2) * rect.width
                drawVLine(context!,cx,rect.origin.y,rect.origin.y + GrphSZ)
            default :
                let cx = rect.origin.x + d.valueRatio(0) * rect.width
                drawVLine(context!,cx,rect.origin.y,rect.origin.y + GrphSZ)
                
                if d.kind == .dualFloat || d.kind == .float3Dual {
                    let y = rect.origin.y + (1.0 - d.valueRatio(1)) * rect.height
                    drawHLine(context!,rect.origin.x,rect.origin.x + GrphSZ,y)
                }
            }
        }
        
        color.set()
        UIBezierPath(rect:rect).stroke()

        let tColor:UIColor = index == focus ? .green : color
        let tab = data[index].kind == .float3Dual ? Tab3+10 : Tab2+10
        drawText(tab,py+TxtYoff,tColor,FontSZ,data[index].str[0])
    }
    
    func drawEntry(_ index:Int) {
        let tColor:UIColor = index == focus ? .green : color
        data[index].yCoord = py
        
        switch(data[index].kind) {
        case .singleFloat, .dualFloat, .move, .float3Dual, .float3Single : drawGraph(index)
        case .dropDown : drawText(Tab1,py+TxtYoff,tColor,FontSZ,data[index].str[data[index].getInt32Value()])
        case .command  : drawText(Tab1,py+TxtYoff,tColor,FontSZ,data[index].str[0])
        case .string   : drawText(Tab1,py+TxtYoff,tColor,FontSZ, (delegate?.wgGetString(data[index].ident))!)
        case .toggle   : drawText(Tab1,py+TxtYoff,tColor,FontSZ, (delegate?.wgGetString(data[index].ident))!)
        case .legend   : drawText(Tab1,py+TxtYoff,.yellow,FontSZ,data[index].str[0])
        case .option   : drawText(Tab1,py+TxtYoff,tColor,FontSZ, (delegate?.wgGetOptionString(data[index].ident))!)

        case .line :
            color.set()
            context?.setLineWidth(1)
            drawHLine(context!,0,bounds.width,py)
            py -= RowHT - 5
            
        case .color :
            let c = (delegate?.wgGetColor(data[index].ident))!
            c.setFill()
            let r = CGRect(x:1, y:py-3, width:bounds.width-2, height:CGFloat(data[index].deltaValue)+2)
            UIBezierPath(rect:r).fill()
            py -= RowHT
            
        case .gap :
            py += CGFloat(data[index].deltaValue)
        }
        
        if data[index].kind != .float3Dual { py += RowHT }
    }
    
    func baseYCoord() -> CGFloat { return 2 }
    
    override func draw(_ rect: CGRect) {
        if vc == nil { return }
        context = UIGraphicsGetCurrentContext()
        
        py = baseYCoord()
        for i in 0 ..< data.count { drawEntry(i) }
        
        color.setStroke()
        UIBezierPath(rect:bounds).stroke()
        
        drawHLine(context!,0,bounds.width,767) // bottom egde of small iPads (1024x768)
    }
    
    func nextYCoord() -> CGFloat {
        py = baseYCoord()
        for i in 0 ..< data.count {
            switch(data[i].kind) {
            case .line  : py -= RowHT - 5
            case .color : py -= RowHT
            case .gap   : py += CGFloat(data[i].deltaValue)
            default : break
            }
            
            py += RowHT
        }
        
        return py
    }
    
    //MARK:-
    
    func float3Value() -> float3 {
        if focus == NONE { return float3() }
        return data[focus].valuePointerX.load(as: float3.self)
    }
    
    func update() -> Bool {
        if focus == NONE { return false }
        if delta == float3() { return false } // marks end of session

        switch data[focus].kind {
        case .float3Dual :   // hardwired to .xy fields of float3
            var v:float3 = float3Value()
            v.x = fClamp2(v.x + delta.x * data[focus].deltaValue, data[focus].mRange)
            v.y = fClamp2(v.y + delta.y * data[focus].deltaValue, data[focus].mRange)
            v.z = fClamp2(v.z + delta.z * data[focus].deltaValue, data[focus].mRange)
            data[focus].valuePointerX.storeBytes(of:v, as:float3.self)
        default :
            if data[focus].isValueWidget() {
                let valueX = fClamp2(data[focus].getFloatValue(0) + delta.x * data[focus].deltaValue, data[focus].mRange)
                data[focus].valuePointerX.storeBytes(of:valueX, as:Float.self)
                
                if data[focus].kind == .dualFloat {
                    let valueY = fClamp2(data[focus].getFloatValue(1) + delta.y * data[focus].deltaValue, data[focus].mRange)
                    data[focus].valuePointerY.storeBytes(of:valueY, as:Float.self)
                }
            }
            else { return false }
        }
        
        delegate?.wgCommand(data[focus].ident)
        setNeedsDisplay()
        return true
    }
    
    func moveFocus(_ dir:Int) {
        if focus == NONE || data.count < 2 { return }
        
        while true {
            focus += dir
            if focus >= data.count { focus = 0 } else if focus < 0 { focus = data.count-1 }
            if [ .singleFloat, .dualFloat, .float3Dual, .float3Single ].contains(data[focus].kind) { break }
        }
        
        if data[focus].kind == .float3Single { // hop past the .z widget of float3() group
            if dir > 0 { focus += 2 }  else { focus -= 1 }
        }

        setNeedsDisplay()
    }
    
    //MARK:-
    
    func stopChanges() { delta = float3() }
    
    func focusMovement(_ pt:CGPoint, _ touchCount:Int) {
        if focus == NONE { return }
        
        if touchCount == 0 { // panning just ended
            stopChanges()
            return
        }
        
        let denom:Float = 1000

        delta.y = -Float(pt.y) / denom        

        let dx = Float(pt.x) / denom
        if touchCount < 2 { delta.x = dx } else { delta.z = dx; delta.y = 0 } // 2 finger pan = .z of float3
        
        if data[focus].kind == .singleFloat {  // largest delta runs the show
            if fabs(delta.y) > fabs(delta.x) { delta.x = delta.y }
        }
        
        // if morphing then always use 'fast edit'
        if !vc.isMorph {
            if !data[focus].fastEdit {
                let den = Float((data[focus].kind == .move) ? 10 : 100)
                delta /= den
            }
        }
        
        setNeedsDisplay()
    }
    
    // MARK:
    
    func optionSelectPopup(_ ident:WgIdent, _ title:String, _ message:String, _ options:[String]) {
        let alert = UIAlertController(title:title, message:message, preferredStyle: .actionSheet)
        
        func attrString(_ text:String, _ key:String) {
            let a1 = NSMutableAttributedString(string: text,
                                               attributes: [kCTFontAttributeName as NSAttributedStringKey:UIFont(name: "Helvetica", size: 24.0)!])
            alert.setValue(a1, forKey: key)
        }
        
        attrString(title,"attributedTitle")
        attrString(message,"attributedMessage")
        
        for i in 0 ..< options.count {
            let sa = UIAlertAction(title: options[i], style: .default) { action -> Void in self.wgOptionSelected(ident,i) }
            alert.addAction(sa)
        }
        
        alert.view.subviews[0].subviews[0].backgroundColor = UIColor.darkGray
        alert.view.tintColor = UIColor.white
        alert.popoverPresentationController?.sourceView = self
        vc.present(alert, animated: true, completion: nil)
    }
    
    //MARK:-
        
    func shouldMemorizeFocus() -> Bool {
        if focus == NONE { return false }
        return [ .singleFloat, .dualFloat, .option, .move ].contains(data[focus].kind)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var pt = CGPoint()
        for touch in touches { pt = touch.location(in: self) }
        stopChanges()
        
        if focus == NONE { vc.removeAllFocus() }
        if shouldMemorizeFocus() { previousFocus = focus }
        
        for i in 0 ..< data.count { // move Focus to this entry?
            if [ .singleFloat, .dualFloat, .command, .toggle, .option, .dropDown, .move, .float3Dual, .float3Single ].contains(data[i].kind) &&
                pt.y >= data[i].yCoord && pt.y < data[i].yCoord + RowHT {
                focus = i
                setNeedsDisplay()
                return
            }
        }
    }
    
    override func touchesMoved(     _ touches: Set<UITouch>, with event: UIEvent?) { touchesBegan(touches, with:event) }
    override func touchesCancelled( _ touches: Set<UITouch>, with event: UIEvent?) { touchesEnded(touches, with:event) }
    
    override func touchesEnded( _ touches: Set<UITouch>, with event: UIEvent?) {
        if focus == NONE { return }
        
        if data[focus].kind == .command {
            delegate?.wgCommand(data[focus].ident)
            
            focus = NONE
            if previousFocus != NONE { focus = previousFocus }
            
            setNeedsDisplay()
            return
        }

        if data[focus].kind == .toggle {
            delegate?.wgToggle(data[focus].ident)
            
            focus = NONE
            if previousFocus != NONE { focus = previousFocus }
            
            setNeedsDisplay()
            return
        }

        if data[focus].kind == .option {
            let p = data[focus]
            optionSelectPopup(p.ident, p.str[0], p.str[1], Array(p.str[2 ..< p.str.count]))
            setNeedsDisplay()
        }
        
        stopChanges()
    }
    
    func fClamp2(_ v:Float, _ range:float2) -> Float {
        if v < range.x { return range.x }
        if v > range.y { return range.y }
        return v
    }
}

// MARK:

func drawLine(_ context:CGContext, _ p1:CGPoint, _ p2:CGPoint) {
    context.beginPath()
    context.move(to:p1)
    context.addLine(to:p2)
    context.strokePath()
}

func drawVLine(_ context:CGContext, _ x:CGFloat, _ y1:CGFloat, _ y2:CGFloat) { drawLine(context,CGPoint(x:x,y:y1),CGPoint(x:x,y:y2)) }
func drawHLine(_ context:CGContext, _ x1:CGFloat, _ x2:CGFloat, _ y:CGFloat) { drawLine(context,CGPoint(x:x1, y:y),CGPoint(x: x2, y:y)) }

func drawRect(_ context:CGContext, _ r:CGRect) {
    context.beginPath()
    context.addRect(r)
    context.strokePath()
}

func drawFilledCircle(_ context:CGContext, _ center:CGPoint, _ diameter:CGFloat, _ color:CGColor) {
    context.beginPath()
    context.addEllipse(in: CGRect(x:CGFloat(center.x - diameter/2), y:CGFloat(center.y - diameter/2), width:CGFloat(diameter), height:CGFloat(diameter)))
    context.setFillColor(color)
    context.fillPath()
}

//MARK:-

var fntSize:CGFloat = 0
var txtColor:UIColor = .clear
var textFontAttributes:NSDictionary! = nil

func drawText(_ x:CGFloat, _ y:CGFloat, _ color:UIColor, _ sz:CGFloat, _ str:String) {
    if sz != fntSize || color != txtColor {
        fntSize = sz
        txtColor = color
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.left
        let font = UIFont.init(name: "Helvetica", size:sz)!
        
        textFontAttributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: color,
            NSAttributedStringKey.paragraphStyle: paraStyle,
        ]
    }
    
    str.draw(in: CGRect(x:x, y:y, width:800, height:100), withAttributes: textFontAttributes as? [NSAttributedStringKey : Any])
}


