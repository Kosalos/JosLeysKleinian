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
        
        let dateString = determineDateString(indexPath.row)
        var str:String = ""
        
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
                control.aData = aData
                saveAndDismissDialog(indexPath.row)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        legend.text = (saveLoadStyle == .settings) ? "Save/Load Settings" : "Save/Load Recordings"
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
                    control.aData = aData
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
            self.dismiss(animated: false, completion: {()->Void in
                vc.controlJustLoaded()
            })
        }
    }
}

//MARK:-

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm"
        return dateFormatter.string(from: self)
    }
}

