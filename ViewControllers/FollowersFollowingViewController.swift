//
//  FollowersFollowingViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 4/5/21.
//

import UIKit
import ChameleonFramework
import Firebase
class FollowersFollowingViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NavBar: UIView!
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private var profiles: [String: UIImage] = [:]
    private var profileName: [String] = []
    private var users: [String] = []
    static var friend: String!
    static var curUser: String!
    override func viewDidLoad() {
        loadFriends()
        super.viewDidLoad()
        doneButton.titleLabel?.textColor = FlatWhite()
        NavBar.backgroundColor = GradientColor(.leftToRight, frame: NavBar.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.backgroundColor = GradientColor(.leftToRight, frame: tableView.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "AddFriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFriendsTableViewCell")
        tableView.separatorStyle = .none
        searchBar.delegate = self
        tableView.rowHeight = 85
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func loadFriends () {
        profiles = [:]
        
        let docRef = db.collection("Users").document(FollowersFollowingViewController.curUser).collection("Profile Information").document("Friends").collection(FollowersFollowingViewController.friend)
        docRef.getDocuments { (shot, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                self.users = []
                for document in shot!.documents {
                    self.users.append(document.documentID)
                }
                for user in self.users {
                    self.db.collection("Users").document(user).collection("Profile Information").document("Username").getDocument { (doc, error) in
                        if let e = error {
                            print(e.localizedDescription)
                        } else if let doc = doc{
                            self.storage.child("Users").child(user).child("Profile Picture").child("Profile Picture.png").getData(maxSize:  4*1024*1024) { (data, error) in
                                if let e = error {
                                    print(e.localizedDescription)
                                } else if let data = data{
                                    self.profiles[doc.data()?["username"] as! String] = UIImage(data: data)
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    

  

}

extension FollowersFollowingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsTableViewCell", for: indexPath) as! AddFriendsTableViewCell
        var newframe = cell.bgView.frame
        newframe.size.width = tableView.frame.size.width
        cell.bgView.frame = newframe
        cell.bgView.backgroundColor = GradientColor(.leftToRight, frame: cell.bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        var keys: [String] = []
        for value in profiles.keys {
            keys.append(value)
        }
        
        cell.contactName.text = keys[indexPath.row]
        cell.profileImage.image = profiles[keys[indexPath.row]]
        cell.profileImage.backgroundColor = FlatBlack()
        cell.contactName.textColor = FlatWhite()
        cell.profileImage.layer.borderWidth = 0.5
        cell.profileImage.layer.borderColor = FlatWhite().cgColor
        return cell
    }
    
    
}

extension FollowersFollowingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == ""{
            loadFriends()
            return
        }
        profiles =  profiles.filter({return $0.key.lowercased().contains(searchBar.text!.lowercased())})
        profileName = profileName.filter({return $0.lowercased().contains(searchBar.text!.lowercased())})
        tableView.reloadData()
        
    }
}
