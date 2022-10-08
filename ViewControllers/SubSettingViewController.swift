//
//  SubSettingViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 1/28/21.
//

import UIKit
import ChameleonFramework
import FirebaseAuth
class SubSettingViewController: UIViewController {
   
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let defaults = UserDefaults.standard
    var data: [String]?
   static var key: String?
        
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource =  self
        tableView.delegate = self
        if let val = SubSettingViewController.key {
            data = defaults.array(forKey: val) as? [String]
            navBar.topItem?.title = val
            
            
        }
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:FlatWhite()]
        navBar.barTintColor = GradientColor(.leftToRight, frame: navBar.bounds, colors: [FlatGreen(), FlatBlue()])
        navBar.isTranslucent = false
        tableView.tableFooterView = footerView
        footerView.backgroundColor = GradientColor(.leftToRight, frame: footerView.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.backgroundColor = GradientColor(.leftToRight, frame: tableView.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       
    }

    

 

}
extension SubSettingViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subSettingCell")!
        cell.textLabel?.text = data?[indexPath.row]
        cell.backgroundColor = GradientColor(.leftToRight, frame: cell.bounds, colors: [FlatGreen(), FlatBlue()])
        cell.textLabel?.textColor = FlatWhite()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.textLabel?.text == "Username"{
                let alert = UIAlertController(title: "Username", message: "Enter Your Display Name", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    //
                }
                let action = UIAlertAction(title: "confirm", style: .default) { (alertAction) in
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                
            }
            if cell.textLabel?.text == "Logout" {
                do {
                    try Auth.auth().signOut()
                    defaults.setValue(false, forKey: "staysignedin")
                    performSegue(withIdentifier: "goToLoginScreen", sender: self)
                } catch let e as NSError{
                    print(e.localizedDescription)
                }
            }
        }
    }
    
    
}
