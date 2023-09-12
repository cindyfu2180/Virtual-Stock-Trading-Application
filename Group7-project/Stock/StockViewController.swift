import UIKit
import Alamofire
import QuartzCore
import Firebase
import FirebaseAuth

extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }
    
  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}

class StockViewController: UIViewController {

    struct stocktype {
          var amount: Double
          var date: Date
          var nolots: Int
          var price: Double
          var id: Int
    }
    var uid = ""
    var total: Double = 0
    var ref: DatabaseReference = Database.database().reference()
    
    
    @IBOutlet weak var input: UISearchBar!
    
    @IBOutlet weak var table: UITableView!
    
    @IBAction func sortButton(_ sender: Any) {
        
        if filterArray.count == objectArray.count{
            var sortedArr = percentArr.sorted{$0 > $1}
            if !pressed {
                pressed = true
            }else {
                sortedArr = sortedArr.reversed()
                pressed = false
            }
            for i in 0...percentArr.count - 1{
                for j in 0...percentArr.count - 1{
                    if sortedArr[i] == percentArr[j] {
                        for k in 0...percentArr.count - 1{
                            if idArr[j] == filterArray[k].id {
                                filterArray.swapAt(i, k)
                            }
                        }
                    }
                }
            }
            table.reloadData()
        }
    }
    
    
    let newsLink = "http://hq.sinajs.cn/list=hk0"
    //http://hq.sinajs.cn/list=hk00388
    
    var idArr = [String]()
    var priceArr = [String]()
    var changeArr = [String]()
    var percentArr = [Double]()
    var dateArr = [String]()
    
    var sPrice = ""
    var sID = ""
    var sChange = ""
    var sPercent = ""
    var sName = ""
    var sDate = ""
    
    var pressed = false
    
    let stock = ["CK Hutchison":"0001", "CLP":"0002", "HK & China Gas":"0003",
                 "HSBC":"0005", "Henderson Land":"0012", "Swire Pacific":"0019", "Tencent":"0700", "HKEX":"0388", "Sunny Optical":"2382", "AIA":"1299", "Link REITs":"0823", "MTR":"0066"]

    struct onlineStock {
        var names: String!
        var id: String!
    }
    
    var searchStock = [String]()
    var workingID = ""
    
    var objectArray:[onlineStock] = []
    var filterArray:[onlineStock] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        for (key, value) in stock {
            objectArray.append(onlineStock(names: key, id: value) )
        }
        filterArray = objectArray
        getData()
        if let user = Auth.auth().currentUser{
            uid = user.uid}
        gettotal()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.table.indexPathForSelectedRow{
            self.table.deselectRow(at: index, animated: true)
        }
        
        gettotal()
    }
}

extension StockViewController {
    
    func getData() {
        for i in 0 ... stock.count - 1{
            let link = newsLink + filterArray[i].id!
            Alamofire.request(link).responseString(completionHandler: { response in
                if let value = response.result.value {
                    
                    let valueArr:[String] = value.components(separatedBy: ",")
                    //print(valueArr)
                    
                    var temp = valueArr[0]
                    let handle = temp.substring(fromIndex: 14)
                    temp = handle.substring(toIndex: 4)
                    
                    self.idArr.append(temp)
                    
                    var cutPrice = valueArr[6]
                    if (cutPrice[2] == "."){
                        cutPrice = cutPrice.substring(toIndex: 5)
                    }else {
                        cutPrice = cutPrice.substring(toIndex: 6)
                    }
                    self.priceArr.append( cutPrice )
                    
                    let myDouble = Double(valueArr[7])
                    if (myDouble!.isLess(than: 0.0)){
                        self.changeArr.append( valueArr[7] )
                    }else {
                        self.changeArr.append( "+" + valueArr[7])
                    }
                    
                    self.percentArr.append( Double(valueArr[8])! )
                    
                    self.dateArr.append( valueArr[17] )
                    
//                    print("open: \(valueArr[2])" )
//                    print("close: \(valueArr[3])")
//                    print("change: \(valueArr[7])")
//                    print("percentageCh: \(valueArr[8])%")
//                    print("Date: \(valueArr[17])")
                    
                } else {
                    print("error: \(String(describing: response.error))")
                }
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            })
        }
    }
    
    func search(stockID: String) {
        
        sID = stockID
        let link = newsLink + stockID
        
        Alamofire.request(link).responseString(completionHandler: { response in
                
            if let value = response.result.value {
                       
                let valueArr:[String] = value.components(separatedBy: ",")
                
                print(valueArr)
                if valueArr.count > 10 {
                    
                    var temp = valueArr[0]
                    let handle = temp.substring(fromIndex: 20)
                    temp = handle.substring(toIndex: handle.count)
                    
                    self.sName = temp
                    
                    self.filterArray.append(onlineStock(names: temp, id: stockID) )
                    print(self.filterArray)
                    
                    self.sPrice = valueArr[6]
                    
                    var myDouble = Double(valueArr[7])
                    if (myDouble!.isLess(than: 0.0)){
                        self.sChange = valueArr[7]
                    }else {
                        self.sChange = "+" + valueArr[7]
                    }
                    
                    myDouble = Double(valueArr[8])
                    if (myDouble!.isLess(than: 0.0)){
                        self.sPercent = valueArr[8] + "%"
                    }else {
                        self.sPercent = "+" + valueArr[8] + "%"
                    }
                    
                    self.sDate = valueArr[17]
                }
            }else {
                print("error: \(String(describing: response.error))")
            }
            
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        })
    }
        
}

extension StockViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "Stock", for:indexPath) as! StockTableCell
        
        cell.name.text = filterArray[indexPath.row].names
        cell.id.text = filterArray[indexPath.row].id
        
        if sChange.length == 0 {
            if priceArr.count > indexPath.row{
                if(idArr[indexPath.row] == filterArray[indexPath.row].id){
                    cell.price.text = priceArr[indexPath.row]
                    cell.dChange.text = changeArr[indexPath.row]
                    if (percentArr[indexPath.row].isLess(than: 0.0) ){
                        cell.percentCh.text = String(percentArr[indexPath.row]) + "%"
                    }else {
                        cell.percentCh.text = "+" + String(percentArr[indexPath.row]) + "%"
                    }
                }else {
                    for i in 0...idArr.count - 1{
                        if(idArr[i] == filterArray[indexPath.row].id){
                            cell.price.text = priceArr[i]
                            cell.dChange.text = changeArr[i]
                            if (percentArr[i].isLess(than: 0.0) ){
                                cell.percentCh.text = String(percentArr[i]) + "%"
                            }else {
                                cell.percentCh.text = "+" + String(percentArr[i]) + "%"
                            }
                        }
                    }
                }
            }
        }else {
            cell.price.text = sPrice
            cell.dChange.text = sChange
            cell.percentCh.text = sPercent
            
            sChange = ""
            sPercent = ""
        }
        if let temp = cell.dChange.text{
            if  (temp[0] == "-") {
                cell.price.textColor = UIColor.systemRed
                cell.percentCh.backgroundColor = UIColor.red
                cell.percentCh.textColor = UIColor.white
                cell.percentCh.font = .boldSystemFont(ofSize: 16.0)
            }else if (temp[0] == "+"){
                cell.price.textColor = UIColor.systemGreen
                cell.percentCh.backgroundColor = UIColor.green
                cell.percentCh.textColor = UIColor.black
                cell.percentCh.font = .systemFont(ofSize: 16.0)
            }
        }
        cell.name.font = .systemFont(ofSize: 15.0)
        cell.id.font = .italicSystemFont(ofSize: 15.0)
        cell.price.font = .boldSystemFont(ofSize: 17.0)
        cell.percentCh.layer.cornerRadius = 10
        return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(filterArray[indexPath.row].id, forKey: "id")
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Archive", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("OK, marked")
            
            Database.database().reference(withPath: "ID/\(self.uid)/watchlist/\(String(self.filterArray[indexPath.row].names))").setValue(self.filterArray[indexPath.row].id)
            
                success(true)
            
            let alert = UIAlertController(title: "Add to watchlist", message: "You can view it in Account->Setting \n ->Watchlist", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            })
            closeAction.backgroundColor = .gray
    
            return UISwipeActionsConfiguration(actions: [closeAction])
    
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
            let modifyAction = UIContextualAction(style: .normal, title:  "BUY", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("Adding ...")
                
                let alert = UIAlertController(title: "Amount of Stock", message: "How many?", preferredStyle: .alert)

                alert.addTextField { (textField) in
                    textField.placeholder = "Number of lot"
                    textField.keyboardType = UIKeyboardType.decimalPad
                }

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    print("Text field: \(textField!.text ?? "0")")
                    var doublePrice = 0.0
                    var errorMsg = ""
                    var stockid = ""
                    var buydate = ""
                    var stockname = ""                    
                    var amount:Double = 0
                    print("break")
                    self.gettotal()
            
                    //Check whether the input amount is valid
                    if let input = Int(textField!.text!) {  //No. of lots must be an integer
                      
                        if self.sPrice.isEmpty {
                            for i in 0...self.priceArr.count - 1{
                                if (self.idArr[i] == self.filterArray[indexPath.row].id) {
                                    doublePrice = Double(self.priceArr[i])!
                                    stockid = self.filterArray[indexPath.row].id
                                    buydate = self.dateArr[i]
                                    stockname = self.filterArray[indexPath.row].names
                                }
                            }
                        }else {
                            doublePrice = Double(self.sPrice)!
                            stockid = self.sID
                            buydate = self.sDate
                            stockname = self.sName
                        }
                        amount = Double(input) * 500.0 * doublePrice
                        var nolots:Int = input
                        print("amount=\(amount)")
                        print("self.total=\(self.total)")
                        if amount.isLess(than: self.total){ //Remaining balance
                            //Valid input action
                        let temp = self.total - amount
                            self.total = temp
                            let stockItemRef = self.ref.child("ID").child(self.uid).child("stock").child(stockid)
                            var stockItem:stockdata? = nil
                            
                            stockItemRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if snapshot.exists(){
                                    print("true rooms exist")
                                    let value = snapshot.value as? NSDictionary
                                    let tempnolot = value?["nolots"] as? Int ?? 0
                                    nolots += tempnolot
                                    let tempamount = Double(nolots) * 500.0 * doublePrice
                                    stockItem = stockdata(amount: tempamount, date: buydate, nolots: nolots, price: doublePrice, id: stockid ,stockname: stockname)
                                    stockItemRef.setValue(stockItem!.toAnyObject(), withCompletionBlock: { (error, ref) in
                                                          if error == nil {
                                                              let alertController = UIAlertController(title: "Success", message: "Buy Successfully", preferredStyle: .alert)
                                                               let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                               alertController.addAction(defaultAction)
                                                               self.present(alertController, animated: true, completion: nil)
                                    }})}else{
                                    stockItem = stockdata(amount: amount, date: buydate, nolots: nolots, price: doublePrice, id: stockid ,stockname: stockname)
                                    stockItemRef.setValue(stockItem!.toAnyObject(), withCompletionBlock: { (error, ref) in
                                                          if error == nil {
                                                              let alertController = UIAlertController(title: "Success", message: "Buy Successfully", preferredStyle: .alert)
                                                               let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                               alertController.addAction(defaultAction)
                                                               self.present(alertController, animated: true, completion: nil)
                                                          }})}})
                            self.gettotal()
                    Database.database().reference(withPath: "ID/\(self.uid)/totalamount").setValue(temp)
                        }else {
                            errorMsg = "Don't have enough balance"
                            print("notenought=\(self.total)")
                        }
                    }else {
                        if Double(textField!.text!) != nil{
                            errorMsg = "Input must be integer"
                        }
                    }
                    if !errorMsg.isEmpty {
                        let alert = UIAlertController(title: "Data Validation Error", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {(action: UIAlertAction!)in print("Data Validation Checking Completed")
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }))

                self.present(alert, animated: true, completion: nil)
                
                success(true)
            })
            modifyAction.backgroundColor = .systemGreen
        
            return UISwipeActionsConfiguration(actions: [modifyAction])
        }
    
}

extension StockViewController: UISearchBarDelegate{
    
//    func updateSearchResults(for searchController: UISearchController) {
//
//        let searchString = searchController.searchBar.text!
//        searchStock = filterArray.filter { (names) -> Bool in
//            return
//        }
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        sPrice = ""
        
        if (!searchText.isEmpty){
            
            let firstDigit = searchText[0]
            
            if Character(firstDigit).isNumber {
                filterArray = searchText.isEmpty ? objectArray : objectArray.filter({
                    (element) -> Bool in
                    return element.id.range(of: searchText) != nil
                })
                //print(filterArray)
                workingID = searchText
                while workingID.count < 4{
                    workingID = "0" + workingID
                }
                if filterArray.isEmpty {
                    search(stockID: workingID)
                }
                
            }else {
                filterArray = searchText.isEmpty ? objectArray : objectArray.filter({
                    (element) -> Bool in
                    return element.names.range(of: searchText, options: .caseInsensitive) != nil
                })
            }
            
        }else {
            filterArray = objectArray
        }
        table.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if !filterArray.isEmpty {
            for i in 0..<filterArray.count{
                if filterArray[i].id == workingID{
                    let alert = UIAlertController(title: "Stock Found", message: "It is already in your watchlist", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    let temp = filterArray[i].names
                    
                    filterArray.removeAll()
                    filterArray.append(onlineStock(names: temp, id: workingID) )
                    self.table.reloadData()
                    break
                }else {
                    if i == filterArray.count - 1 {
                        let alert = UIAlertController(title: "No Result", message: "Your list doesn't contain stock: " + workingID + "\n Do you want to search for it?", preferredStyle: UIAlertController.Style.alert)
                                    
                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                                    
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                                        (action: UIAlertAction!) in
                                        
                        self.filterArray.removeAll()
                        self.search(stockID: self.workingID)
                        self.table.reloadData()
                                        
                        let alert = UIAlertController(title: "Success", message: "Search result has been shown", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                                        
                        //                DispatchQueue.main.async {
                        //                    self.updateWatchList()
                        //                }
                        }))
                                    
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }else {
            let alert = UIAlertController(title: "Failed", message: "This stock doesn't exist", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func gettotal(){
        Database.database().reference(withPath: "ID/\(self.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        let value = snapshot.value as? NSDictionary
        self.total = value?["totalamount"] as? Double ?? 0
        print("total = \(self.total)")
        }) { (error) in
        print(error.localizedDescription)
        }
    }
    
    
    
}
