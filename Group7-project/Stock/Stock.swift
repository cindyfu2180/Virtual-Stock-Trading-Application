//
//  Stock.swift
//  iosproject
//
//  Created by tommylung on 13/11/2019.
//  Copyright © 2019 tommylung. All rights reserved.
//
import Foundation
import Firebase
struct stockdata {
    let key: String
    var amount: Double
    var date: String
    var nolots: Int
    var price: Double
    var id: String
    var stockname: String

    init(amount: Double, date: String, nolots: Int, price: Double, id:String, stockname: String, key: String = "") {
        self.key = key
        self.amount = amount
        self.date = date
        self.nolots = nolots
        self.price = price
        self.id = id
        self.stockname = stockname

    
    }
    init(snapshot: DataSnapshot) {
              key = snapshot.key
              let snapshotValue = snapshot.value as! [String: AnyObject]
              amount = snapshotValue["amount"] as! Double
              date = snapshotValue["date"] as! String
              nolots = snapshotValue["nolots"] as! Int
              price = (snapshotValue["price"] as? Double)!
              id = snapshotValue["id"] as! String
              stockname = snapshotValue["stockname"] as! String
//              ref = snapshot.ref
    }
    func toAnyObject() -> Any {
        return [
            "amount": amount,
            "date": date,
            "nolots": nolots,
            "price": price,
            "id": id,
            "stockname": stockname
        ]
    }
//    private func uploadDataToFirebase(values: stockdata) {
//        let stockItem = stockdata(amount: values.amount, date: values.date, nolots: values.nolots, price: values.price, id: values.id)
//        let stockItemRef = self.ref!.child(values.id)
//        stockItemRef.setValue(stockItem.toAnyObject(), withCompletionBlock: { (error, ref) in
//            if error == nil {
//                let alertController = UIAlertController(title: "Success", message: "Upload Successfully", preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertController.addAction(defaultAction)
//                self.present(alertController, animated: true, completion: nil)
//            }
//        })
//    }
}
