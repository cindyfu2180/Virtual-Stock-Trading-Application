//
//  ViewController.swift
//  Project-account
//
//  Created by Jeffrey Wong on 3/11/2019.
//  Copyright © 2019 ee4304-project. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseAuth
import Alamofire
import QuartzCore

class AccountViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var AccountName: UIButton!
    @IBOutlet weak var total_balance: UILabel!
    @IBOutlet weak var current_balance: UILabel!
    @IBOutlet weak var balance_change: UILabel!
    @IBOutlet weak var balance_change_image: UIImageView!
    
    struct stockStruct {
        var id:String
        var stockName:String
        var boughtAmount:Double
        var boughtPrice:Double
        var presentPrice:Double
        var date:String
        var changeBalance:Double
        var changePercentage:Double
        var nolots:Int
    }
    
    var ref: DatabaseReference = Database.database().reference()
    var uid = ""
    var stockitem:[stockStruct] = []
    var balance: Double = 0
    var money: Double = 0
    var chart_id : [String] = []
    var chart_value: [Double] = []

    var newItem: [stockdata] = []
    var total:Double = 0
    var newItems: [stockdata] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.stockitem = []
        self.balance = 0
        self.chart_id = []
        self.chart_value = []
        self.setPieChart(dataPoints: self.chart_id, values: self.chart_value)
        if let user = Auth.auth().currentUser{
                    uid = user.uid }
        self.ref =  Database.database().reference(withPath: "ID/\(self.uid)/stock")
                    self.ref.observe(.value, with: { (snapshot) in
                        self.newItems = []
                        for item in snapshot.children {
                            let stocks = stockdata(snapshot: item as! DataSnapshot)
                            print("newstock")
                            self.newItems.append(stocks)
                        }
                        self.chart_id = []
                        self.chart_value = []

                        self.stockitem = []
                        for stock in self.newItems {
                            self.getStockData(StockID: stock.id, boughtPrice:stock.price, boughtAmmount: stock.amount, boughtDate:stock.date, nolots: stock.nolots)
                        }
        })

        self.ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
          let username = value?["Name"] as? String ?? ""
            print(username)
            self.AccountName.setTitle(username, for: UIControl.State())
            print("getName")
          }) { (error) in
            print(error.localizedDescription)
        }
        self.ref = Database.database().reference(withPath: "ID/\(self.uid)/totalamount")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value
            print(value!)
            self.money = value! as! Double
            self.current_balance.text = "$\(self.money)"
            self.total_balance.text = "$\(self.money+self.balance)"
            self.balance_change.text = "$\(self.balance)"
          }) { (error) in
            print(error.localizedDescription)
        }
//        for n in 0...self.stockitem.count{
//            if(n > 0){
//            if(self.stockitem[n].boughtAmount == 0){
//                self.stockitem.remove(at: n)
//            }
//        }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pieChartView.delegate = self
        if let user = Auth.auth().currentUser{
        uid = user.uid }
    //  reload()
        self.total_balance.text = "$\(self.money+self.balance)"
        self.balance_change.text = "$\(self.balance)"
        
    }
    
    
    func setPieChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: "dataPoints[i] as AnyObject")
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(128))
            let blue = Double(arc4random_uniform(128))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        pieChartView.animate(xAxisDuration: 1.0)
        pieChartView.centerText = "Your Current Portfolio"
        pieChartDataSet.sliceSpace = 2
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        pieChartView.legend.entries = []
    }
    
    func getStockData(StockID: String, boughtPrice:Double, boughtAmmount: Double, boughtDate:String, nolots:Int){
        let newsLink = "http://hq.sinajs.cn/list=hk0"
        let stockLink = newsLink + StockID
        self.stockitem = []
        self.chart_id = []
        self.chart_value = []
        
        Alamofire.request(stockLink).responseString(completionHandler: { response in
            
            self.chart_id = []
            self.chart_value = []
            var moneychange:Double = 0
            var moneyamount:Double = 0
            if let value = response.result.value {
                var valueArr:[String] = value.components(separatedBy: "\"")
                valueArr = valueArr[1].components(separatedBy: ",")
                for item in valueArr{
                    print(item)
                }
                let price = Double(valueArr[6])
                let balance = (boughtPrice-price!)/boughtPrice*boughtAmmount
                let balancePercentage = (boughtPrice-price!)/boughtPrice*100
                
                self.balance = balance
                
                if (self.stockitem.contains(where: {$0.id == StockID}) != true) {
                    self.stockitem.append(stockStruct(id: StockID, stockName: valueArr[0], boughtAmount: boughtAmmount, boughtPrice: boughtPrice, presentPrice: price!, date: boughtDate, changeBalance: balance, changePercentage: balancePercentage, nolots: nolots))
                }
                
            }
            
            
            for stock in self.stockitem {
                moneychange = moneychange + stock.changeBalance
                moneyamount = moneyamount + stock.boughtAmount
            }
            moneychange = moneychange.roundTo(places: 2)
            if moneychange > 0 {
                self.balance_change_image.image = UIImage(systemName: "arrowtriangle.up")
            } else {
                self.balance_change_image.image = UIImage(systemName: "arrowtriangle.down")
            }
            for stock in self.stockitem {
                
                self.chart_id.append(stock.id)
                self.chart_value.append((stock.changeBalance + stock.boughtAmount)/(moneyamount + moneychange)*100)
                
            }
            print("1234567\(self.chart_id)")
            print(self.stockitem)
            
            
            self.total_balance.text = "$\(self.money + moneyamount + moneychange)"
            self.balance_change.text = "$\(moneychange)"
            self.setPieChart(dataPoints: self.chart_id, values: self.chart_value)

        })
    
    }
    func reload(){
        
        Database.database().reference(withPath: "ID/\(self.uid)/stock").observe(.value, with: { (snapshot) in
                               self.newItems = []
                               for item in snapshot.children {
                                   let stocks = stockdata(snapshot: item as! DataSnapshot)
                                   print("newstock")
                                   self.newItems.append(stocks)
                               }
                               self.chart_id = []
                               self.chart_value = []

                               self.stockitem = []
                               for stock in self.newItems {
                                   self.getStockData(StockID: stock.id, boughtPrice:stock.price, boughtAmmount: stock.amount, boughtDate:stock.date, nolots: stock.nolots)
                               }
               })
//        Database.database().reference(withPath: "ID/\(self.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
//        // Get user value
//        let value = snapshot.value as? NSDictionary
//        self.total = value?["totalamount"] as? Double ?? 0
//        }) { (error) in
//        print(error.localizedDescription)
//        }
//        self.ref =  Database.database().reference(withPath: "ID/\(self.uid)/stock")
//        self.ref.observe(.value, with: { (snapshot) in
//        self.newItem=[]
//        for item in snapshot.children {
//        let stocks = stockdata(snapshot: item as! DataSnapshot)
//        self.newItem.append(stocks)
//        }
//        })
//        print(self.newItem)
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let item = stockitem[Int(highlight.x)]
        
        var errorMsg = ""
        let sellid = String(item.id)
        print(sellid)
        var nolots:Int = 0
        var amount:Double = 0
        var price:Double = 0
        
        
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
        
        let alert = UIAlertController(title: "Bought Stock Info", message: "Stock ID: \(item.id)\n Bought Date: \(item.date) \n Bought Price: \(item.boughtPrice) \n Nolots: \(item.nolots) \n Bought Ammount: \(item.boughtAmount)", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Sell"
            textField.keyboardType = UIKeyboardType.numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sell", style: .default, handler: {
            [weak alert] (_) in
                let textField = alert?.textFields![0]
                print("Text field: \(textField!.text ?? "0")")
        
                //Check whether the input amount is valid
                if let input = Int(textField!.text!) {  //No. of lots must be an integer
                    if(input < item.nolots){
                        let templots = item.nolots - input
                        let tempamount:Double = Double(input) * 500.0 * price
                        amount -= tempamount
                        self.ref = Database.database().reference(withPath: "ID/\(self.uid)/stock/\(sellid)")
                        self.ref.child("amount").setValue(amount)
                        self.ref.child("nolots").setValue(templots)
                        self.total += Double(input) * 500.0 * item.presentPrice
                        Database.database().reference(withPath: "ID/\(self.uid)/totalamount").setValue(self.total)
                   //     self.viewWillAppear(true)
                        self.reload()
                        
                    }else if(input == nolots){
                        self.total += Double(input) * 500.0 * item.presentPrice
                        Database.database().reference(withPath: "ID/\(self.uid)/totalamount").setValue(self.total)
                        self.ref = Database.database().reference(withPath: "ID/\(self.uid)/stock/\(sellid)")
                        self.ref.removeValue()
                        self.reload()
                        
                  //      self.viewWillAppear(true)

                        
                        
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
   //     self.viewDidLoad()
        self.viewWillAppear(true)
        self.present(alert, animated: true, completion: nil)
    }
}



extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

