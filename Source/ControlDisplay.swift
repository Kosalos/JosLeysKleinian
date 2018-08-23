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

func displayControlGeneratorAsSourceCode() {
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

//MARK:-

func cData_213907957() {
    control.aData.transformMatrix.columns.0 = float4(-0.427233, 0.854248, 0.285693, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.508599, -0.0297228, 0.855205, 0.0)
    control.aData.transformMatrix.columns.2 = float4(0.742594, 0.512773, -0.423508, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(-0.427233, 0.854248, 0.285693)
    control.aData.endPosition.columns.1 = float3(0.508599, -0.0297228, 0.855205)
    control.aData.endPosition.columns.2 = float3(0.742594, 0.512773, -0.423508)
    control.camera = float3(-0.62042, 0.91706,-1.12144)
    control.focus = float3(-0.56956, 0.91409,-1.03592)
    control.InvCenter = float3( 0.51560, 1.04560, 0.65940)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.50000, 0.31760, 0.00000)
    control.viewVector = float3( 0.05086,-0.00297, 0.08552)
    control.topVector = float3( 0.08537,-0.00499,-0.05095)
    control.sideVector = float3( 0.00581, 0.09938, 0.00000)
    control.lighting.position = float3(-10.00000, 0.66450, 1.60550)
    control.zoom =  0.68937
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog = 32.00000
    control.epsilon =  0.00001
    control.normalEpsilon =  0.00181
    control.fFinal_Iterations =  8.20700
    control.fBox_Iterations = 13.30100
    control.fMaxSteps = 116.48500
    control.Clamp_y =  0.69540
    control.Clamp_DF =  0.01000
    control.box_size_z =  0.25345
    control.box_size_x =  1.00075
    control.KleinR =  2.46565
    control.KleinI =  2.07310
    control.DeltaAngle =  5.41149
    control.InvRadius =  0.76310
    control.deScale =  1.19175
    control.lighting.diffuse =  0.38425
    control.lighting.specular =  0.53825
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = true
    control.DoInversion = true
    control.FourGen = false
}

func cData_751773953() {
    control.aData.transformMatrix.columns.0 = float4(0.232064, 0.925199, 0.290966, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.572533, -0.370477, 0.72862, 0.0)
    control.aData.transformMatrix.columns.2 = float4(0.784605, -0.00220096, -0.6172, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(0.232064, 0.925199, 0.290966)
    control.aData.endPosition.columns.1 = float3(0.572533, -0.370477, 0.72862)
    control.aData.endPosition.columns.2 = float3(0.784605, -0.00220096, -0.6172)
    control.camera = float3( 0.01644, 1.92750,-1.27547)
    control.focus = float3( 0.07370, 1.89045,-1.20261)
    control.InvCenter = float3( 1.04160, 0.51120, 0.89590)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.50000, 0.00000, 0.12970)
    control.viewVector = float3( 0.05725,-0.03705, 0.07286)
    control.topVector = float3( 0.06117,-0.03958,-0.06819)
    control.sideVector = float3( 0.05422, 0.08378, 0.00000)
    control.lighting.position = float3(-10.00000, 0.66450, 1.60550)
    control.zoom =  1.04446
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog = 32.00000
    control.epsilon =  0.05000
    control.normalEpsilon =  0.01841
    control.fFinal_Iterations =  1.93650
    control.fBox_Iterations =  4.63700
    control.fMaxSteps = 71.57999
    control.Clamp_y =  1.39050
    control.Clamp_DF =  0.40955
    control.box_size_z =  2.00000
    control.box_size_x =  0.18355
    control.KleinR =  1.91590
    control.KleinI =  0.01000
    control.DeltaAngle =  5.57474
    control.InvRadius =  1.13060
    control.deScale =  0.35150
    control.lighting.diffuse =  0.99775
    control.lighting.specular =  0.53825
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = false
    control.DoInversion = true
    control.FourGen = true
}


func cData_18849015() {
    control.aData.transformMatrix.columns.0 = float4(-0.736323, -0.661444, -0.00320503, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.102154, -0.124481, 0.975902, 0.0)
    control.aData.transformMatrix.columns.2 = float4(-0.650241, 0.717191, 0.156769, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(-0.736323, -0.661444, -0.00320503)
    control.aData.endPosition.columns.1 = float3(0.102154, -0.124481, 0.975902)
    control.aData.endPosition.columns.2 = float3(-0.650241, 0.717191, 0.156769)
    control.camera = float3( 0.30218, 1.21196,-0.69120)
    control.focus = float3( 0.31239, 1.19951,-0.59361)
    control.InvCenter = float3( 0.51560, 1.04560, 0.65940)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.50000, 0.31760, 0.00000)
    control.viewVector = float3( 0.01022,-0.01245, 0.09759)
    control.topVector = float3( 0.06191,-0.07544,-0.01610)
    control.sideVector = float3( 0.07646, 0.06275, 0.00000)
    control.lighting.position = float3( 3.06500,-1.10250, 1.60550)
    control.zoom =  0.68937
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog = 32.00000
    control.epsilon =  0.00001
    control.normalEpsilon =  0.00035
    control.fFinal_Iterations =  8.20700
    control.fBox_Iterations =  9.08650
    control.fMaxSteps = 116.48500
    control.Clamp_y =  0.57770
    control.Clamp_DF =  0.01000
    control.box_size_z =  0.19690
    control.box_size_x =  1.20460
    control.KleinR =  2.26615
    control.KleinI =  0.01945
    control.DeltaAngle =  6.65724
    control.InvRadius =  0.78095
    control.deScale =  0.28800
    control.lighting.diffuse =  0.01225
    control.lighting.specular =  0.73587
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = true
    control.DoInversion = true
    control.FourGen = false
}

func cData_931709051() {
    control.aData.transformMatrix.columns.0 = float4(-0.733163, -0.663878, 0.0405787, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.116066, -0.0743435, 0.97945, 0.0)
    control.aData.transformMatrix.columns.2 = float4(-0.651587, 0.721602, 0.129194, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(-0.733163, -0.663878, 0.0405787)
    control.aData.endPosition.columns.1 = float3(0.116066, -0.0743435, 0.97945)
    control.aData.endPosition.columns.2 = float3(-0.651587, 0.721602, 0.129194)
    control.camera = float3( 0.27806, 0.82645, 0.19023)
    control.focus = float3( 0.28966, 0.81902, 0.28817)
    control.InvCenter = float3( 0.58910, 1.03710, 0.89590)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.50000, 0.00000, 0.12970)
    control.viewVector = float3( 0.01161,-0.00743, 0.09794)
    control.topVector = float3( 0.08248,-0.05283,-0.01378)
    control.sideVector = float3( 0.05335, 0.08329, 0.00000)
    control.lighting.position = float3(-10.00000, 0.66450, 1.60550)
    control.zoom =  0.68937
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog = 32.00000
    control.epsilon =  0.00131
    control.normalEpsilon =  0.00001
    control.fFinal_Iterations =  8.20700
    control.fBox_Iterations =  9.08650
    control.fMaxSteps = 116.48500
    control.Clamp_y =  0.23385
    control.Clamp_DF =  0.01000
    control.box_size_z =  0.26395
    control.box_size_x =  1.47325
    control.KleinR =  1.44805
    control.KleinI =  1.06390
    control.DeltaAngle =  6.65724
    control.InvRadius =  0.78095
    control.deScale =  0.28800
    control.lighting.diffuse =  0.01225
    control.lighting.specular =  0.53825
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = false
    control.DoInversion = true
    control.FourGen = false
}

func cData_915138006() {
    control.aData.transformMatrix.columns.0 = float4(0.866904, -0.448934, -0.214204, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.149398, -0.176233, 0.972507, 0.0)
    control.aData.transformMatrix.columns.2 = float4(-0.474345, -0.875546, -0.0854382, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(0.866904, -0.448934, -0.214204)
    control.aData.endPosition.columns.1 = float3(0.149398, -0.176233, 0.972507)
    control.aData.endPosition.columns.2 = float3(-0.474345, -0.875546, -0.0854382)
    control.camera = float3( 0.40190, 1.36504,-1.93767)
    control.focus = float3( 0.41684, 1.34742,-1.84042)
    control.InvCenter = float3( 0.58910, 1.03710, 0.89590)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.50000, 0.00000, 0.38440)
    control.viewVector = float3( 0.01494,-0.01762, 0.09725)
    control.topVector = float3( 0.06289,-0.07418,-0.02310)
    control.sideVector = float3( 0.07625, 0.06464,-0.00000)
    control.lighting.position = float3(-1.60150, 9.67950, 5.13200)
    control.zoom =  1.04446
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog = 32.00000
    control.epsilon =  0.00985
    control.normalEpsilon =  0.00001
    control.fFinal_Iterations =  8.20700
    control.fBox_Iterations =  9.08650
    control.fMaxSteps = 63.45000
    control.Clamp_y =  0.73780
    control.Clamp_DF =  0.52615
    control.box_size_z =  2.00000
    control.box_size_x =  0.31795
    control.KleinR =  2.33365
    control.KleinI =  0.01000
    control.DeltaAngle =  5.57474
    control.InvRadius =  1.13060
    control.deScale =  0.35150
    control.lighting.diffuse =  0.62475
    control.lighting.specular =  1.00000
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = false
    control.DoInversion = true
    control.FourGen = true
}

func cData_274078011() {
    control.aData.transformMatrix.columns.0 = float4(-0.713185, -0.670662, -0.147182, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.000513359, -0.218246, 0.964729, 0.0)
    control.aData.transformMatrix.columns.2 = float4(-0.68314, 0.687068, 0.152914, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(-0.713185, -0.670662, -0.147182)
    control.aData.endPosition.columns.1 = float3(0.000513359, -0.218246, 0.964729)
    control.aData.endPosition.columns.2 = float3(-0.68314, 0.687068, 0.152914)
    control.camera = float3( 0.43667, 0.62142,-0.43523)
    control.focus = float3( 0.43672, 0.59959,-0.33876)
    control.InvCenter = float3( 0.35400, 0.91420, 0.02340)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.43290, 0.00180, 0.36250)
    control.viewVector = float3( 0.00005,-0.02182, 0.09647)
    control.topVector = float3( 0.00023,-0.09647,-0.02183)
    control.sideVector = float3( 0.09891, 0.00023,-0.00000)
    control.lighting.position = float3(-8.57350,-0.95400,-7.35100)
    control.zoom =  0.61410
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog =  5.00000
    control.epsilon =  0.00001
    control.normalEpsilon =  0.00097
    control.fFinal_Iterations = 35.26099
    control.fBox_Iterations = 16.68599
    control.fMaxSteps = 67.28500
    control.Clamp_y =  0.63855
    control.Clamp_DF =  0.00100
    control.box_size_z =  0.75335
    control.box_size_x =  0.97720
    control.KleinR =  1.80595
    control.KleinI =  1.73470
    control.DeltaAngle =  7.13254
    control.InvRadius =  0.36560
    control.deScale =  0.37500
    control.lighting.diffuse =  0.71137
    control.lighting.specular =  0.79450
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = true
    control.DoInversion = true
    control.FourGen = false
}

func cData_112239003() {
    control.aData.transformMatrix.columns.0 = float4(1.0, 0.0, 0.0, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.0, 1.0, 0.0, 0.0)
    control.aData.transformMatrix.columns.2 = float4(0.0, 0.0, 1.0, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(1.0, 0.0, 0.0)
    control.aData.endPosition.columns.1 = float3(0.0, 1.0, 0.0)
    control.aData.endPosition.columns.2 = float3(0.0, 0.0, 1.0)
    control.camera = float3( 1.76505,-1.52394,-3.83825)
    control.focus = float3( 1.75008,-1.49413,-3.74424)
    control.InvCenter = float3( 0.35400, 0.91420, 0.02340)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.05930, 0.50000, 0.36250)
    control.viewVector = float3(-0.01497, 0.02981, 0.09401)
    control.topVector = float3(-0.04217, 0.08401,-0.03336)
    control.sideVector = float3(-0.08915,-0.04475,-0.00000)
    control.lighting.position = float3(-8.57350,-0.95400,-7.35100)
    control.zoom =  0.61410
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog =  5.00000
    control.epsilon =  0.00001
    control.normalEpsilon =  0.01706
    control.fFinal_Iterations = 35.26099
    control.fBox_Iterations = 16.68599
    control.fMaxSteps = 121.01000
    control.Clamp_y =  0.63855
    control.Clamp_DF =  0.00100
    control.box_size_z =  0.75335
    control.box_size_x =  0.97720
    control.KleinR =  1.88740
    control.KleinI =  1.83325
    control.DeltaAngle =  7.13254
    control.InvRadius =  0.36560
    control.deScale =  0.37500
    control.lighting.diffuse =  0.71137
    control.lighting.specular =  0.79450
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = true
    control.DoInversion = true
    control.FourGen = false
}

func cData_666895985() {
    control.aData.transformMatrix.columns.0 = float4(0.23841, 0.898065, 0.362133, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.575061, -0.42983, 0.693169, 0.0)
    control.aData.transformMatrix.columns.2 = float4(0.780849, 0.043396, -0.62043, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(0.23841, 0.898065, 0.362133)
    control.aData.endPosition.columns.1 = float3(0.575061, -0.42983, 0.693169)
    control.aData.endPosition.columns.2 = float3(0.780849, 0.043396, -0.62043)
    control.camera = float3(-1.19190, 2.14935,-2.13445)
    control.focus = float3(-1.13440, 2.10637,-2.06514)
    control.InvCenter = float3( 1.13060, 0.87050, 0.91050)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.50000, 0.00000, 0.12970)
    control.viewVector = float3( 0.05751,-0.04298, 0.06932)
    control.topVector = float3( 0.05552,-0.04150,-0.07180)
    control.sideVector = float3( 0.05975, 0.07993,-0.00000)
    control.lighting.position = float3(-10.00000, 0.66450, 1.60550)
    control.zoom =  1.04446
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog = 32.00000
    control.epsilon =  0.00001
    control.normalEpsilon =  0.01787
    control.fFinal_Iterations =  1.93650
    control.fBox_Iterations =  5.10050
    control.fMaxSteps = 71.57999
    control.Clamp_y =  0.44475
    control.Clamp_DF =  0.40955
    control.box_size_z =  2.00000
    control.box_size_x =  0.26740
    control.KleinR =  1.30045
    control.KleinI =  0.01000
    control.DeltaAngle =  5.57474
    control.InvRadius =  1.40240
    control.deScale =  0.35150
    control.lighting.diffuse =  0.99775
    control.lighting.specular =  0.53825
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = false
    control.DoInversion = true
    control.FourGen = true
}

func cData_321149945() {
    control.aData.transformMatrix.columns.0 = float4(1.0, 0.0, 0.0, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.0, 1.0, 0.0, 0.0)
    control.aData.transformMatrix.columns.2 = float4(0.0, 0.0, 1.0, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(1.0, 0.0, 0.0)
    control.aData.endPosition.columns.1 = float3(0.0, 1.0, 0.0)
    control.aData.endPosition.columns.2 = float3(0.0, 0.0, 1.0)
    control.camera = float3(-1.73144,-0.03971,-1.29021)
    control.focus = float3(-1.65198,-0.03113,-1.23010)
    control.InvCenter = float3( 1.49930, 0.67410, 0.91050)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.50000, 0.00000, 0.50000)
    control.viewVector = float3( 0.07946, 0.00858, 0.06011)
    control.topVector = float3( 0.05976, 0.00645,-0.07992)
    control.sideVector = float3(-0.01074, 0.09943, 0.00000)
    control.lighting.position = float3( 0.75350,-2.66250,-3.08500)
    control.zoom =  1.04446
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog = 32.00000
    control.epsilon =  0.00001
    control.normalEpsilon =  0.00036
    control.fFinal_Iterations =  1.93650
    control.fBox_Iterations =  5.10050
    control.fMaxSteps = 71.57999
    control.Clamp_y =  0.44475
    control.Clamp_DF =  0.00100
    control.box_size_z =  1.92985
    control.box_size_x =  0.26740
    control.KleinR =  2.24275
    control.KleinI =  0.01000
    control.DeltaAngle =  6.51084
    control.InvRadius =  1.40240
    control.deScale =  0.55325
    control.lighting.diffuse =  0.67200
    control.lighting.specular =  0.35262
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = true
    control.DoInversion = true
    control.FourGen = false
}

func cData_501476049() {
    control.aData.transformMatrix.columns.0 = float4(-0.715014, -0.679794, -0.081465, 0.0)
    control.aData.transformMatrix.columns.1 = float4(0.0370018, -0.16166, 0.975104, 0.0)
    control.aData.transformMatrix.columns.2 = float4(-0.680157, 0.693125, 0.13788, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(-0.715014, -0.679794, -0.081465)
    control.aData.endPosition.columns.1 = float3(0.0370018, -0.16166, 0.975104)
    control.aData.endPosition.columns.2 = float3(-0.680157, 0.693125, 0.13788)
    control.camera = float3( 0.55739, 0.65247, 0.66265)
    control.focus = float3( 0.56109, 0.63631, 0.76016)
    control.InvCenter = float3( 0.60150, 0.60430, 1.50000)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.32740, 0.04800, 0.06670)
    control.viewVector = float3( 0.00370,-0.01617, 0.09751)
    control.topVector = float3( 0.02176,-0.09505,-0.01658)
    control.sideVector = float3( 0.09642, 0.02207,-0.00000)
    control.lighting.position = float3( 4.02500,10.00000, 6.57200)
    control.zoom =  1.08030
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog =  5.00000
    control.epsilon =  0.00055
    control.normalEpsilon =  0.00127
    control.fFinal_Iterations = 35.26099
    control.fBox_Iterations = 12.42799
    control.fMaxSteps = 67.28500
    control.Clamp_y =  0.63855
    control.Clamp_DF =  0.00100
    control.box_size_z =  0.75335
    control.box_size_x =  0.81700
    control.KleinR =  1.93240
    control.KleinI =  0.52163
    control.DeltaAngle =  7.13254
    control.InvRadius =  0.36560
    control.deScale =  0.37500
    control.lighting.diffuse =  0.60587
    control.lighting.specular =  0.62538
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = true
    control.DoInversion = true
    control.FourGen = false
}

func cData_330147027() {
    control.aData.transformMatrix.columns.0 = float4(1.0, -1.09053e-05, 0.000835411, 0.0)
    control.aData.transformMatrix.columns.1 = float4(1.08843e-05, 1.0, 2.51465e-05, 0.0)
    control.aData.transformMatrix.columns.2 = float4(-0.000835411, -2.51374e-05, 1.0, 0.0)
    control.aData.transformMatrix.columns.3 = float4(0.0, 0.0, 0.0, 1.0)
    control.aData.endPosition.columns.0 = float3(1.0, -1.09053e-05, 0.000835411)
    control.aData.endPosition.columns.1 = float3(1.08843e-05, 1.0, 2.51465e-05)
    control.aData.endPosition.columns.2 = float3(-0.000835411, -2.51374e-05, 1.0)
    control.camera = float3( 0.53590, 0.58906, 1.16655)
    control.focus = float3( 0.53590, 0.68906, 1.16655)
    control.InvCenter = float3( 0.66780, 0.90120, 1.40580)
    control.ReCenter = float3( 0.00000, 0.00000, 0.14680)
    control.color = float3( 0.41940, 0.28770, 0.06670)
    control.viewVector = float3( 0.00000, 0.10000, 0.00000)
    control.topVector = float3( 0.00000, 0.00000,-0.10000)
    control.sideVector = float3(-0.10000, 0.00000, 0.00000)
    control.lighting.position = float3( 4.02500,10.00000,-3.04400)
    control.zoom =  1.08030
    control.deFactor1 =  0.00000
    control.deFactor2 =  0.00000
    control.parallax =  0.00110
    control.fog =  5.00000
    control.epsilon =  0.00001
    control.normalEpsilon =  0.00111
    control.fFinal_Iterations =  9.74400
    control.fBox_Iterations =  4.31999
    control.fMaxSteps = 51.66000
    control.Clamp_y =  0.63855
    control.Clamp_DF =  0.00100
    control.box_size_z =  0.23185
    control.box_size_x =  0.95260
    control.KleinR =  1.93240
    control.KleinI =  0.29020
    control.DeltaAngle =  8.50323
    control.InvRadius =  0.71675
    control.deScale =  0.53200
    control.lighting.diffuse =  0.60587
    control.lighting.specular =  0.62538
    control.lighting.saturation =  0.00000
    control.lighting.gamma =  0.00000
    control.ShowBalls = false
    control.DoInversion = true
    control.FourGen = true
}

let defaultRecordingsList = [ cData_213907957,cData_751773953,cData_18849015,cData_931709051,cData_915138006,cData_274078011,cData_112239003,cData_666895985,cData_321149945,
                              cData_501476049,cData_330147027 ]
