import UIKit

protocol SLCellDelegate: class {
    func didTapButton(_ sender: UIButton)
}

class SaveLoadCell: UITableViewCell {
    weak var delegate: SLCellDelegate?
    @IBOutlet var loadCell: UIButton!
    @IBAction func buttonTapped(_ sender: UIButton) {  delegate?.didTapButton(sender) }
}

enum SaveLoadStyle { case settings,recordings }

var saveLoadStyle:SaveLoadStyle = .settings

//MARK:-

let versionNumber:Int32 = 0x55ab

class SaveLoadViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,SLCellDelegate {
    var cc = Control()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var legend: UILabel!
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 50 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SLCell", for: indexPath) as! SaveLoadCell
        cell.delegate = self
        cell.tag = indexPath.row

        var str:String = ""
        
        let dateString = determineDateString(indexPath.row)
        
        if dateString == "**" {
            str = "** unused **"
            cell.loadCell.backgroundColor = UIColor.black
        }
        else {
            str = String(format:"%2d    %@", indexPath.row+1,dateString)
            cell.loadCell.backgroundColor = UIColor(red:0.1, green:0.5, blue:0.4, alpha:1)
        }
        
        cell.loadCell.setTitle(str, for: UIControlState.normal)
        return cell
    }
    
    func didTapButton(_ sender: UIButton) {
        func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
            let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
            if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
                return indexPath
            }
            return nil
        }
        
        if let indexPath = getCurrentCellIndexPath(sender) {
            //Swift.print("Row ",indexPath.row, "        Tag ", sender.tag)
            
            if sender.tag == 0 { // load
                loadAndDismissDialog(indexPath.row)
            }
            
            if sender.tag == 1 { // save
                control.version = versionNumber
                control.aData = vc.aData
                saveAndDismissDialog(indexPath.row)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        legend.text = (saveLoadStyle == .settings) ? "Save/Load Settings" : "Save/Load Recordings"

        // ----------------------------------------
        if control.fog > 100 {          // set breakpoint here, then in console:   expr control.fog = 999
            savingsToSourceCode()
            return
        }

        let cc = control
        if !loadData(0) {       // NO saves == new Install. save default datasets
            sourceCodeToSavings()
        }
        control = cc
    }
    
    //MARK:-
    
    var fileURL:URL! = nil
    
    func determineURL(_ index:Int) {
        let name = (saveLoadStyle == .settings) ? String(format:"Store%d.dat",index) : String(format:"Record%d.dat",index)
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(name)
    }
    
    func saveAndDismissDialog(_ index:Int) {
        var alertController:UIAlertController! = nil
        if saveLoadStyle == .settings {
            alertController = UIAlertController(title: "Save Settings", message: "Confirm overwrite of Settings storage", preferredStyle: .alert)
        } else {
            alertController = UIAlertController(title: "Save Recording", message: "Confirm overwrite of Recording storage", preferredStyle: .alert)
        }
        
        let OKAction = UIAlertAction(title: "Continue", style: .default) { (action:UIAlertAction!) in
            do {
                self.determineURL(index)
                var data:NSData! = nil
                
                if saveLoadStyle == .settings {
                    control.version = versionNumber
                    control.aData = vc.aData
                    data = NSData(bytes:&control, length:MemoryLayout<Control>.size)
                }
                
                try data.write(to: self.fileURL, options: .atomic)
            } catch {
                print(error)
            }
            
            self.dismiss(animated: false, completion:nil)
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            return
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    //MARK:-
    
    var dateString = String("")
    
    func determineDateString(_ index:Int) -> String {
        var dStr = String("**")
        
        determineURL(index)
        
        do {
            let key:Set<URLResourceKey> = [.creationDateKey]
            let value = try fileURL.resourceValues(forKeys: key)
            if let date = value.creationDate { dStr = date.toString() }
        } catch {
            // print(error)
        }
        
        return dStr
    }
    
    //MARK:-
    
    @discardableResult func loadData(_ index:Int) -> Bool {
        determineURL(index)
        
        let data = NSData(contentsOf: fileURL)
        if data == nil { return false } // clicked on empty entry
        
        if saveLoadStyle == .settings {
            data?.getBytes(&control, length:MemoryLayout<Control>.size)
        }
        
        return true
    }
    
    func loadAndDismissDialog(_ index:Int) {
        if !loadData(index) { return } // clicked on empty entry
        
        if saveLoadStyle == .settings {
            if control.version != versionNumber { vc.reset() }
        }
        
        if saveLoadStyle == .settings {
            self.dismiss(animated: false, completion: {()->Void in vc.controlJustLoaded() })
        }
    }
    
    //MARK:-
    
    let cSize = MemoryLayout<Control>.stride
    
    func savingsToSourceCode() {
        print("\n\nlet base64List:[String] = [")
        
        for i in 0 ..< 50 {
            if !loadData(i) { break }
            
            let data = Data(bytes:&control, count: cSize)
            print(String(format:"    \"%@\",",data.base64EncodedString()))
        }
        
        print("]")
    }
    
    func sourceCodeToSavings() {
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: cSize)
        
        for i in 0 ..< base64List.count {
            let data = Data(base64Encoded: base64List[i])!
            data.copyBytes(to: pointer, count:cSize)
            memcpy(&control,pointer,cSize)

            do {
                self.determineURL(i)
                try data.write(to: self.fileURL, options: .atomic)
            } catch {
                print(error)
            }
        }
    }
    
    let base64List:[String] = [
        "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",
        ]
}

//MARK:-

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm"
        return dateFormatter.string(from: self)
    }
}
