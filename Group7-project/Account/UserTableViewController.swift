//
//  UserTableViewController.swift
//  Group7-project
//
//  Created by Jeffrey Wong on 13/11/2019.
//  Copyright © 2019 ee4304-gp7-project. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserTableViewController: UITableViewController {
    
    @IBOutlet weak var NameLabel: UILabel!
    var uid = ""
    var ref: DatabaseReference = Database.database().reference()
    
    @IBAction func changeName(_ sender: Any) {
        let alert = UIAlertController(title: "Change Name", message: "Please input your name", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "name"
            textField.keyboardType = UIKeyboardType.default
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            
            let name = String( alert.textFields![0].text! )
            print(String(name))
            if( name.count > 0 ){
                Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name").setValue(name)
            }else {
                let alert = UIAlertController(title: "Data Validation Error", message: "Input cannot be empty", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {(action: UIAlertAction!)in print("Data Validation Checking Completed")
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            self.viewWillAppear(true)

        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    // Hide the Navigation Bar
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        
            if let user = Auth.auth().currentUser{
            uid = user.uid }
            self.ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
              let value = snapshot.value as? NSDictionary
              let username = value?["Name"] as? String ?? ""
                print(username)
                self.NameLabel.text = username
              }) { (error) in
                print(error.localizedDescription)
            }
        }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    // Show the Navigation Bar
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }
    @IBAction func Logout(_ sender: Any) {
        if Auth.auth().currentUser != nil {
                    do {
                     try Auth.auth().signOut()
        //                self.performSegue(withIdentifier: "goBack", sender: nil)
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
