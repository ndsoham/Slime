//
//  ViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 1/15/21.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController {


    @IBOutlet weak var staySignedInButton: UIButton!
    @IBOutlet weak var staySignedInLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordIcon: UIImageView!
    @IBOutlet weak var usernameIcon: UIImageView!
    @IBOutlet weak var loginItemsContainer: UIView!
    @IBOutlet var bgView: UIView!
    let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
      
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        GIDSignIn.sharedInstance()?.delegate = self
        super.viewDidLoad()
        bgView.backgroundColor = GradientColor(.topToBottom, frame: bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        loginItemsContainer.backgroundColor = .clear
        usernameIcon.tintColor = FlatBlue()
        usernameIcon.layer.borderColor = FlatBlue().cgColor
        usernameIcon.layer.borderWidth = 1
        passwordIcon.tintColor = FlatBlue()
        passwordIcon.layer.borderColor = FlatBlue().cgColor
        passwordIcon.layer.borderWidth = 1
        staySignedInButton.tintColor = FlatWhite()
        staySignedInButton.layer.borderColor = FlatWhite().cgColor
        staySignedInButton.layer.borderWidth = 1
    }
    override func viewWillDisappear(_ animated: Bool) {
        if staySignedInButton.currentBackgroundImage == UIImage(systemName: "checkmark") {
           
            defaults.setValue(true, forKey: "staysignedin")
        } else {
            defaults.setValue(false, forKey: "staysignedin")
        }
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = usernameTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else {return}
                print(strongSelf)
                if let e = error{
                    let alert = UIAlertController(title: "Error Logging In", message: e.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    guard let curUser = Auth.auth().currentUser else{
                        fatalError("curUser is null")
                    }
                    let docData: [String:String] = [
                        "username": curUser.email!
                    ]
                    let docRef = self?.db.collection("Users")
                    var cont = false
                    docRef?.getDocuments(completion: { (snapshot, error) in
                        if let e = error {
                            print(e.localizedDescription)
                        } else if let shot = snapshot {
                            for document in shot.documents {
                                if document.documentID == docData["username"] {
                                    cont = true
                                }
                            }
                            if cont == false {
                                
                                self?.db.collection("Users").document(curUser.email!).collection("Profile Information").document("Username").setData(docData)
                                self?.db.collection("Users").document(curUser.email!).setData(["Random Field": "r"])
                                let imageData = #imageLiteral(resourceName: "Slime").pngData()
                                let uploadMetaData = StorageMetadata.init()
                                uploadMetaData.contentType = "image/png"
                                Storage.storage().reference().child("Users").child(curUser.email!).child("Profile Picture").child("Profile Picture.png").putData(imageData!, metadata: uploadMetaData)
                            }
                        }
                    })
                   
                    
                    self?.performSegue(withIdentifier: "userLoggedIn", sender: self)
                }
            }
        }
    }
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignUpScreen", sender: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email:", preferredStyle: .alert)
        alert.addTextField { (textField) in
            
            textField.textColor = .black
        }
        alert.addAction(UIAlertAction(title: "Send Email", style: .default, handler: { (action) in
            Auth.auth().sendPasswordReset(withEmail: (alert.textFields?.first?.text)!) { (error) in
                var message = ""
                if let e = error{
                    if e.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted."{
                         message = "User does not exist"
                        
                    } else {
                        message = e.localizedDescription
                    }
                        let alert = UIAlertController(title: "Unexpexted Error", message: message, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        
                    
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func staySignedInButtonPressed(_ sender: UIButton) {
        if(sender.currentBackgroundImage == UIImage(systemName: "checkmark") ) {
            sender.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(systemName: "checkmark"), for: .normal)
        }
    }
    
}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let e = error {
            print(e.localizedDescription)
            return
        }
        
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if let e = error {
                let alert = UIAlertController(title: "Error Logging In", message: e.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                guard let curUser = Auth.auth().currentUser else {
                    fatalError("something is wrong")
                }
                let docData: [String:String] = [
                    "username": curUser.email!
                ]
               
                var cont = false
                self.db.collection("Users").getDocuments { (snapshot, error) in
                    if let e = error {
                        print(e.localizedDescription)
                    } else  {
                        for document in snapshot!.documents {
                            if document.documentID == curUser.email {
                                cont = true
                            }
                        }
                        if cont == false {
                            print("im here \(curUser.email!)")
                            self.db.collection("Users").document(curUser.email!).collection("Profile Information").document("Username").setData(docData)
                            self.db.collection("Users").document(curUser.email!).setData(["Random Field": "r"])
                            let imageData = #imageLiteral(resourceName: "Slime").pngData()
                            let uploadMetaData = StorageMetadata.init()
                            uploadMetaData.contentType = "image/png"
                            Storage.storage().reference().child("Users").child(curUser.email!).child("Profile Picture").child("Profile Picture.png").putData(imageData!, metadata: uploadMetaData)
                            
                        }
                        
                    }
                }
               
                self.performSegue(withIdentifier: "userLoggedIn", sender: self)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
}


