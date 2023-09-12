//
//  SellTableCell.swift
//  iosproject
//
//  Created by tommylung on 13/11/2019.
//  Copyright © 2019 tommylung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Alamofire

class SellTableCell: UITableViewCell{

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var priceno: UILabel!
    
    override func prepareForReuse() {
      super.prepareForReuse()
  }
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }
}



class SellTable: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var ref: DatabaseReference = Database.database().reference()
    var uid = ""
    var newItems: [stockdata] = []
    var total:Double = 0
    var currentprice:Double = 0
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newItems.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Sell", for:indexPath) as! SellTableCell
        cell.amount?.text = String(newItems[indexPath.row].amount)
        cell.Date?.text = String(newItems[indexPath.row].date)
        cell.id?.text = String(newItems[indexPath.row].id)
        cell.priceno?.text = "Price:" + String(newItems[indexPath.row].price) + " Num:" + String(newItems[indexPath.row].nolots)
        cell.name?.text = String(newItems[indexPath.row].stockname)
        return cell
    }
    
    @IBAction func test(_ sender: Any) {
        print(self.newItems)
        table.reloadData()
    }
    func reload(){
        Database.database().reference(withPath: "ID/\(self.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        let value = snapshot.value as? NSDictionary
        self.total = value?["totalamount"] as? Double ?? 0
        }) { (error) in
        print(error.localizedDescription)
        }
        self.ref =  Database.database().reference(withPath: "ID/\(self.uid)/stock")
        self.ref.observe(.value, with: { (snapshot) in
        self.newItems=[]
        for item in snapshot.children {
        let stocks = stockdata(snapshot: item as! DataSnapshot)
        self.newItems.append(stocks)
        }
        })
        print(self.newItems)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser{
        uid = user.uid }
        reload()
}
    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//           let delid = String(newItems[indexPath.row].id)
//           print("total=\(self.total)")
//           print("amount=\(newItems[indexPath.row].amount)")
//           let temp = self.total + newItems[indexPath.row].amount
//           self.total = temp
//           newItems.remove(at: indexPath.row)
//           print(newItems.count)
//           Database.database().reference(withPath: "ID/\(self.uid)/totalamount").setValue(temp)
//           Database.database().reference(withPath: "ID/\(self.uid)/stock/\(delid)").removeValue()
//           table.reloadData()
//
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
       
                table.reloadData()
    }
    
    
    
    
    
      func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
        {
            let modifyAction = UIContextualAction(style: .normal, title:  "Sell", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("Selling ...")
                var errorMsg = ""
                                   let sellid = String(self.newItems[indexPath.row].id)
                                   print(sellid)
                                   var nolots:Int = 0
                                   var amount:Double = 0
                                   var price:Double = 0
                                   self.getStockData(StockID: sellid)
                                   
                                   self.ref = Database.database().reference(withPath: "ID/\(self.uid)/stock/\(sellid)")
                                   self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                            // Get user value
                                            let value = snapshot.value as? NSDictionary
                                            nolots = value?["nolots"] as? Int ?? 0
                                            amount = value?["amount"] as? Double ?? 0
                                            price = value?["price"] as? Double ?? 0
                                            }) { (error) in
                                              print(error.localizedDescription)
                                          }
                
                let alert = UIAlertController(title: "Amount of Stock", message: "How many?", preferredStyle: .alert)

                alert.addTextField { (textField) in
                    textField.placeholder = "Number of lot"
                    textField.keyboardType = UIKeyboardType.decimalPad
                }

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    print("Text field: \(textField!.text ?? "0")")
            
                    //Check whether the input amount is valid
                    if let input = Int(textField!.text!) {  //No. of lots must be an integer
                        if(input < nolots){
                            let templots = nolots - input
                            let tempamount:Double = Double(input) * 500.0 * price
                            amount -= tempamount
                            self.ref.child("amount").setValue(amount)
                            self.ref.child("nolots").setValue(templots)
                            self.total += Double(input) * 500.0 * self.currentprice
                            Database.database().reference(withPath: "ID/\(self.uid)/totalamount").setValue(self.total)
                            self.reload()
                            
                            
                            
                        }else if(input == nolots){
                            self.total += Double(input) * 500.0 * self.currentprice
                            Database.database().reference(withPath: "ID/\(self.uid)/totalamount").setValue(self.total)
                            self.ref.removeValue()
                            self.reload()                          
                            
                            
                        }
                        else{
                            errorMsg = "Input must be smaller than \(nolots)"
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
            table.reloadData()
        
            return UISwipeActionsConfiguration(actions: [modifyAction])
        }
    
    
    func getStockData(StockID: String){
           let newsLink = "http://hq.sinajs.cn/list=hk0"
           let stockLink = newsLink + StockID
           
           
           Alamofire.request(stockLink).responseString(completionHandler: { response in

               if let value = response.result.value {
                   var valueArr:[String] = value.components(separatedBy: "\"")
                   valueArr = valueArr[1].components(separatedBy: ",")
                   for item in valueArr{
                       print(item)
                   }
                self.currentprice = Double(valueArr[6])!
                   
               }

           })
       }
    
    
    
}
