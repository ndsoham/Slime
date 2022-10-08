//
//  AddFriendsViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 3/11/21.
//

import UIKit
import ChameleonFramework
import Firebase
class AddFriendsViewController: UIViewController {

    @IBOutlet weak var slimeLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet var bgView: UIView!
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private var profiles: [String:UIImage] = [:]
    private var profileName: [String] = []
    private var users: [String] = []
    override func viewDidLoad() {
        loadFriends()
        super.viewDidLoad()
        navBar.backgroundColor = GradientColor(.leftToRight, frame: navBar.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.backgroundColor = GradientColor(.leftToRight, frame: tableView.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "AddFriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFriendsTableViewCell")
        tableView.separatorStyle = .none
        searchBar.delegate = self
        tableView.rowHeight = 85
        slimeLabel.textColor = FlatWhite()
    }
    func loadFriends() {
        profiles = [:]
        let docRef = db.collection("Users")
        docRef.getDocuments { (snapshot, error) in
            if let e = error {
                print(e.localizedDescription)
            } else if let shot = snapshot {
                self.profiles = [:]
                self.profileName = []
                self.users = []
                for document in shot.documents {
                    guard let username = Auth.auth().currentUser?.email else {fatalError("no one is signed in")}
                    if document.documentID == username {
                        continue
                    }
                     
                    let ref = self.db.collection("Users").document(document.documentID).collection("Profile Information").document("Username")
                    let ref2 = self.storage.child("Users").child(document.documentID).child("Profile Picture").child("Profile Picture.png")
                    
                    ref.getDocument { (doc, error) in
                        if let e = error {
                            print(e.localizedDescription)
                        } else if let doc = doc {
                            
                            ref2.getData(maxSize: 4*1024*1024) { (data, error) in
                                if let e = error {
                                    print(e.localizedDescription)
                                } else if let data = data{
                                    
                                    self.profiles[doc.data()?["username"] as! String] = UIImage(data: data)
                                    self.profileName.append(doc.data()?["username"] as! String)
                                    self.users.append(doc.reference.parent.parent!.documentID)
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
extension AddFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsTableViewCell", for: indexPath) as! AddFriendsTableViewCell
        var newframe = cell.bgView.frame
        newframe.size.width = tableView.frame.size.width
        cell.bgView.frame = newframe
        cell.bgView.backgroundColor = GradientColor(.leftToRight, frame: cell.bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        cell.contactName.text = profileName[indexPath.row]
        cell.profileImage.image = profiles[profileName[indexPath.row]]
        cell.profileImage.backgroundColor = FlatBlack()
        cell.contactName.textColor = FlatWhite()
        cell.profileImage.layer.borderWidth = 0.5
        cell.profileImage.layer.borderColor = FlatWhite().cgColor
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
       
        FriendsHomePageViewController.profilePic = profiles[profileName[indexPath.row]]
        FriendsHomePageViewController.displayName = profileName[indexPath.row]
        FriendsHomePageViewController.friend = users[indexPath.row]
        //print(users)
        //print(profileName)
        performSegue(withIdentifier: "goToFriendsHomepage", sender: self)
    }
    
    
    
}
extension AddFriendsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
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
