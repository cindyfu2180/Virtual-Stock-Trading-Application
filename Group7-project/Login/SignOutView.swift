//
//  SignOutView.swift
//  iosproject
//
//  Created by tommylung on 9/11/2019.
//  Copyright © 2019 tommylung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
//struct users: Codable{
//    var amount: Double
//    var stock: [stock]
//}

class SignOutView: UIViewController {
     var ref: DatabaseReference = Database.database().reference()
     var abc = ""
    var uid = ""
    @IBOutlet weak var NameField: UITextField!
    @IBOutlet weak var Number: UITextField!
   
    @IBOutlet weak var check: UITextField!
    @IBOutlet weak var lab1: UILabel!
    
    @IBOutlet weak var lab2: UILabel!
    
    @IBOutlet weak var lab3: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Auth.auth().currentUser?.email
        checkemail.text = email
        if let user = Auth.auth().currentUser{
            uid = user.uid }
     

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var checkemail: UILabel!
    
    @IBAction func Signout(_ sender: Any) {
        if Auth.auth().currentUser != nil {
               do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "goBack", sender: self)
                   
               } catch let error as NSError {
                   print(error.localizedDescription)
               }
           }
    }
    
    
   
    
    

    @IBOutlet weak var stock: UITextField!

    @IBOutlet weak var num: UITextField!
    
    @IBOutlet weak var date: UITextField!
    
    @IBAction func buy(_ sender: Any) {
//        let stockdata = stock.text
//       let numdata = num.text!
//       let datedata = date.text!
//
//        Database.database().reference(withPath: "ID/\(self.uid)/\(String( stockdata!))").setValue("")
//      Database.database().reference(withPath: "ID/\(self.uid)/\(String( stockdata!))/num").setValue("\(numdata)")
//        Database.database().reference(withPath: "ID/\(self.uid)/\(String( stockdata!))/date").setValue("\(datedata)")
        
         self.ref =  Database.database().reference(withPath: "ID/\(self.uid)/watchlist")
        self.ref.observe(.value, with: { (snapshot) in
                       var newItems: [Any] = []
                       for item in snapshot.children {
                        let stocks = (item as! DataSnapshot)
                           newItems.append(stocks)
                       }
            print(newItems[0])
        })
     
        
    }


    @IBAction func readdata(_ sender: Any) {
    //    let checkstock = check.text!
       // Database.database().reference(withPath: "ID/\(self.uid)").observe(.value, with: { (snapshot) in
         
            self.ref =  Database.database().reference(withPath: "ID/\(self.uid)/stock")
            self.ref.observe(.value, with: { (snapshot) in
                var newItems: [stockdata] = []
                for item in snapshot.children {
                    let stocks = stockdata(snapshot: item as! DataSnapshot)
                    newItems.append(stocks)
                }
                print(newItems)
                print(newItems[0])
                print(newItems[0].key)
                print(newItems[0].nolots)
                print(newItems[0].date)
                
            })

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
}
