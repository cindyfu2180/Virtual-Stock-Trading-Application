//
//  ResetPasswordViewController.swift
//  Group7-project
//
//  Created by Jeffrey Wong on 13/11/2019.
//  Copyright © 2019 ee4304-gp7-project. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    var email = ""
    var uid = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        email = String((Auth.auth().currentUser?.email)!)
        if let user = Auth.auth().currentUser{
            uid = user.uid }

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var EmailField: UITextField!
    @IBAction func ResetPassword(_ sender: Any) {
        if self.EmailField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        
        } else {
            if(self.EmailField.text != email){
                let alertController = UIAlertController(title: "Oops!", message: "Please enter a correct email.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            }else{
         Auth.auth().sendPasswordReset(withEmail: self.EmailField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.EmailField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
            }}
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
