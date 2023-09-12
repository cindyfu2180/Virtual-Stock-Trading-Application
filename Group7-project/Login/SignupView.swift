//
//  SignupView.swift
//  iosproject
//
//  Created by tommylung on 9/11/2019.
//  Copyright © 2019 tommylung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupView: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var NameField: UITextField!
    @IBOutlet weak var Conformpassword: UITextField!
    
    
    var uid = ""
    let uniqueString = NSUUID().uuidString      
      override func viewDidLoad() {
          super.viewDidLoad()
     
        if let user = Auth.auth().currentUser{
              uid = user.uid
          }
        emailField.delegate = self
        passwordField.delegate = self
        NameField.delegate = self
        Conformpassword.delegate = self
      }
    @IBAction func Signup(_ sender: Any) {
        if (emailField.text == "" || passwordField.text == "" || NameField.text == "" || Conformpassword.text == "") {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        
        } else if (passwordField.text != Conformpassword.text) {
            let alertController = UIAlertController(title: "Error", message: "Please conform your password!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }else{
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                if error == nil {
                   
                    if let user = Auth.auth().currentUser{
                                           self.uid = user.uid
                                       }
                   
                    Database.database().reference(withPath: "ID/\(self.uid)/Profile/Safety-Check").setValue("ON")
                    Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name").setValue(self.NameField.text)
                    Database.database().reference(withPath: "ID/\(self.uid)/totalamount").setValue(2000000)
                    } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


