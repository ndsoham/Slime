//
//  SignUpViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 1/15/21.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var loginItemsContainer: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordIcon: UIImageView!
    @IBOutlet weak var usernameIcon: UIImageView!
    @IBOutlet var bgView: UIView!
    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.backgroundColor = GradientColor(.topToBottom, frame: bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        usernameIcon.tintColor = FlatBlue()
        usernameIcon.layer.borderColor = FlatBlue().cgColor
        usernameIcon.layer.borderWidth = 1
        passwordIcon.tintColor = FlatBlue()
        passwordIcon.layer.borderColor = FlatBlue().cgColor
        passwordIcon.layer.borderWidth = 1
        registerButton.backgroundColor = GradientColor(.leftToRight, frame: registerButton.bounds, colors: [FlatGreen(), FlatBlue()])
        loginItemsContainer.backgroundColor = .clear
        navigationBar.barTintColor = FlatGreen()
        navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = usernameTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { [self] (authResult, error) in
                if let e = error {
                    let alert = UIAlertController(title: "Error Creating Account", message: e.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
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

}
