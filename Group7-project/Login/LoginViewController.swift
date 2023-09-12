//
//  ViewController.swift
//  iosproject
//
//  Created by tommylung on 9/11/2019.
//  Copyright © 2019 tommylung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener { (auth, user) in
             if user != nil {
                 self.performSegue(withIdentifier: "Home", sender: nil)
             }
        }}
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }


    @IBAction func Signin(_ sender: Any) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        if self.emailField.text == "" || self.passwordField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        
        } else {
            
            Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                
                if error == nil {
                    self.performSegue(withIdentifier: "Home", sender: self)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        if self.emailField.text == "" {
               let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
               
               let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
               alertController.addAction(defaultAction)
               
               present(alertController, animated: true, completion: nil)
           
           } else {
            Auth.auth().sendPasswordReset(withEmail: self.emailField.text!, completion: { (error) in
                   
                   var title = ""
                   var message = ""
                   
                   if error != nil {
                       title = "Error!"
                       message = (error?.localizedDescription)!
                   } else {
                       title = "Success!"
                       message = "Password reset email sent."
                       self.emailField.text = ""
                   }
                   
                   let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                   
                   let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                   alertController.addAction(defaultAction)
                   
                   self.present(alertController, animated: true, completion: nil)
               })
           }
    }
    

}

