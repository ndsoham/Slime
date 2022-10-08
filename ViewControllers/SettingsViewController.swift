//
//  SettingsViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 1/25/21.
//

import UIKit
import ChameleonFramework

class SettingsViewController: UIViewController {
    private var data = ["Account","Privacy", "Notifications", "Help", "About", "Friends" ]
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var subViewOfFooterView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = footerView
        footerView.backgroundColor = GradientColor(.leftToRight, frame: footerView.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.backgroundColor = GradientColor(.leftToRight, frame: footerView.bounds, colors: [FlatGreen(), FlatBlue()])
        navBar.barTintColor = GradientColor(.leftToRight, frame: footerView.bounds, colors: [FlatGreen(), FlatBlue()])
        navBar.isTranslucent = false
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        searchBar.isTranslucent = false
        defaults.setValue(["Username", "Reset Password", "Logout"], forKey: "Account")
        defaults.setValue([""], forKey: "Privacy")
        defaults.setValue([""], forKey: "Notifications")
        defaults.setValue([""], forKey: "Help")
        defaults.setValue([""], forKey: "About")
        defaults.setValue([""], forKey: "Friends")
//        print("width\(searchBar.frame.width)")
//        print("height\(searchBar.frame.height)")
//        print("green\(FlatGreen().hexValue())")
//        print("blue\(FlatBlue().hexValue())")
        searchBar.searchTextField.backgroundColor = FlatWhite()
        

    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let tag = sender.superview?.superview?.tag {
            if let cell = tableView.cellForRow(at: IndexPath(row: tag, section: 0)) {
                print("im here")
                SubSettingViewController.key = cell.textLabel?.text
            }
        }
        performSegue(withIdentifier: "goToSubSettings", sender: self)
    }
    
 

}
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        cell.backgroundColor = GradientColor(.leftToRight, frame: cell.bounds, colors: [FlatGreen(), FlatBlue()])
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.tag = indexPath.row
        return cell
    }
        
    
}
