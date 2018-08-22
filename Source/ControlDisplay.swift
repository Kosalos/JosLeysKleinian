//    http://www.fractalforums.com/3d-fractal-generation/an-escape-tim-algorithm-for-kleinian-group-limit-sets/45/

func controlDisplay() {
    if vc.tv.isHidden { return }
    
    var s = String()
    func addString(_ str:String) { s += str; s += "\n" }
    
    addString("JosLeys  Strange Attractor")
    addString(" ")
    addString(String(format:"InvCenter = float3(%8.5f,%8.5f,%8.5f);",control.InvCenter.x,control.InvCenter.y,control.InvCenter.z));
    addString(String(format:"ReCenter = float3(%8.5f,%8.5f,%8.5f);",control.ReCenter.x,control.ReCenter.y,control.ReCenter.z));
    addString(String(format:"MaxSteps = %d;",control.maxSteps));
    addString(String(format:"Final_Iterations = %d;",control.Final_Iterations));
    addString(String(format:"Box_Iterations = %d;",control.Box_Iterations));
    addString(String(format:"ShowBalls = %d;",control.ShowBalls ? 1 : 0));
    addString(String(format:"DoInversion = %d;",control.DoInversion ? 1 : 0));
    addString(String(format:"FourGen = %d;",control.FourGen ? 1 : 0));
    addString(String(format:"Clamp_y = %8.5f;",control.Clamp_y));
    addString(String(format:"box_size_z = %8.5f;",control.box_size_z));
    addString(String(format:"box_size_x = %8.5f;",control.box_size_x));
    addString(String(format:"KleinR = %8.5f;",control.KleinR));
    addString(String(format:"KleinI = %8.5f;",control.KleinI));
    addString(String(format:"DeltaAngle = %8.5f;",control.DeltaAngle));
    addString(String(format:"InvRadius = %8.5f;",control.InvRadius));
    addString(String(format:"deScale = %8.5f;",control.deScale));

    vc.tv.text = s
}
