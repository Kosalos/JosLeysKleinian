//    http://www.fractalforums.com/3d-fractal-generation/an-escape-tim-algorithm-for-kleinian-group-limit-sets/45/

func controlDisplay() {
    if vc.tv.isHidden { return }
    
    var s = String()
    func addString(_ str:String) { s += str; s += "\n" }
    
    addString("JosLeys  Strange Attractor")
    addString(" ")
    addString(String(format:"camera = float3(%8.5f,%8.5f,%8.5f);",control.camera.x,control.camera.y,control.camera.z));
    addString(String(format:"focus = float3(%8.5f,%8.5f,%8.5f);",control.focus.x,control.focus.y,control.focus.z));
    addString(String(format:"InvCenter = float3(%8.5f,%8.5f,%8.5f);",control.InvCenter.x,control.InvCenter.y,control.InvCenter.z));
    addString(String(format:"ReCenter = float3(%8.5f,%8.5f,%8.5f);",control.ReCenter.x,control.ReCenter.y,control.ReCenter.z));
    addString(String(format:"MaxSteps = %d;",control.maxSteps));
    addString(String(format:"Final_Iterations = %d;",control.Final_Iterations));
    addString(String(format:"Box_Iterations = %d;",control.Box_Iterations));
    addString(String(format:"ShowBalls = %d;",control.ShowBalls ? 1 : 0));
    addString(String(format:"DoInversion = %d;",control.DoInversion ? 1 : 0));
    addString(String(format:"FourGen = %d;",control.FourGen ? 1 : 0));
    addString(String(format:"Clamp_y = %8.5f;",control.Clamp_y));
    addString(String(format:"Clamp_DF = %8.5f;",control.Clamp_DF));
    addString(String(format:"box_size_z = %8.5f;",control.box_size_z));
    addString(String(format:"box_size_x = %8.5f;",control.box_size_x));
    addString(String(format:"KleinR = %8.5f;",control.KleinR));
    addString(String(format:"KleinI = %8.5f;",control.KleinI));
    addString(String(format:"DeltaAngle = %8.5f;",control.DeltaAngle));
    addString(String(format:"InvRadius = %8.5f;",control.InvRadius));
    addString(String(format:"deScale = %8.5f;",control.deScale));
    addString(String(format:"epsilon = %8.5f;",control.epsilon));
    addString(String(format:"normalEpsilon = %8.5f;",control.normalEpsilon));

    vc.tv.text = s
}

func uniqueFunctionName() -> String { return String(format:"func cData_%d() {",Calendar.current.component(.nanosecond, from: Date()) ) }

func zdisplayControlGeneratorAsSourceCode() {
    let ts = String("    ")

    func boolString(_ legend:String, _ v:Bool) {  print(String(format:"%@control.%@ = %@",ts,legend,v ? "true" : "false")) }
    func floatString(_ legend:String, _ v:Float) {  print(String(format:"%@control.%@ = %8.5f",ts,legend,v)) }
    func float3String(_ legend:String, _ v:float3) { print(String(format:"%@control.%@ = float3(%8.5f,%8.5f,%8.5f)",ts,legend,v.x,v.y,v.z)) }
    func stringString(_ legend:String, _ v:String) { print(String(format:"%@control.%@ = %@",ts,legend,v)) }
    
    control.aData = vc.aData
    
    print("\n\n")
    print(uniqueFunctionName())

    stringString("aData.transformMatrix.columns.0",control.aData.transformMatrix.columns.0.debugDescription)
    stringString("aData.transformMatrix.columns.1",control.aData.transformMatrix.columns.1.debugDescription)
    stringString("aData.transformMatrix.columns.2",control.aData.transformMatrix.columns.2.debugDescription)
    stringString("aData.transformMatrix.columns.3",control.aData.transformMatrix.columns.3.debugDescription)
    stringString("aData.endPosition.columns.0",control.aData.endPosition.columns.0.debugDescription)
    stringString("aData.endPosition.columns.1",control.aData.endPosition.columns.1.debugDescription)
    stringString("aData.endPosition.columns.2",control.aData.endPosition.columns.2.debugDescription)

    float3String("camera",control.camera)
    float3String("focus",control.focus)
    float3String("InvCenter",control.InvCenter)
    float3String("ReCenter",control.ReCenter)
    float3String("color",control.color)
    float3String("viewVector",control.viewVector)
    float3String("topVector",control.topVector)
    float3String("sideVector",control.sideVector)
    float3String("lighting.position",control.lighting.position)
    floatString("zoom",control.zoom)
    floatString("deFactor1",control.deFactor1)
    floatString("deFactor2",control.deFactor2)
    floatString("parallax",control.parallax)
    floatString("fog",control.fog)
    floatString("epsilon",control.epsilon)
    floatString("normalEpsilon",control.normalEpsilon)
    floatString("fFinal_Iterations",control.fFinal_Iterations)
    floatString("fBox_Iterations",control.fBox_Iterations)
    floatString("fMaxSteps",control.fMaxSteps)
    floatString("Clamp_y",control.Clamp_y)
    floatString("Clamp_DF",control.Clamp_DF)
    floatString("box_size_z",control.box_size_z)
    floatString("box_size_x",control.box_size_x)
    floatString("KleinR",control.KleinR)
    floatString("KleinI",control.KleinI)
    floatString("DeltaAngle",control.DeltaAngle)
    floatString("InvRadius",control.InvRadius)
    floatString("deScale",control.deScale)
    floatString("lighting.diffuse",control.lighting.diffuse)
    floatString("lighting.specular",control.lighting.specular)
    floatString("lighting.saturation",control.lighting.saturation)
    floatString("lighting.gamma",control.lighting.gamma)
    boolString("ShowBalls",control.ShowBalls)
    boolString("DoInversion",control.DoInversion)
    boolString("FourGen",control.FourGen)
    print("}")
}
