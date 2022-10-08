//
//  CommentsViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 4/7/21.
//

import UIKit
import ChameleonFramework
import Firebase
protocol commentsViewControllerDelegate {
    func commentsWillDisappear(_ comments: Int)
}
class CommentsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checklistStackView: UIStackView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var addCommentsTextField: UITextField!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var acView: UIView!
    @IBOutlet weak var tableView: UITableView!
    static var user: String!
    static var post: String!
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private var comments: [String:[String:[Any]]] = [:]
    static var delegate: commentsViewControllerDelegate!
    override func viewDidLoad() {
        loadComments()
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 85
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        acView.backgroundColor = .clear
        tableView.backgroundColor = .clear
        headerView.backgroundColor = .clear
        bgView.backgroundColor = GradientColor(.leftToRight, frame: bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        commentsLabel.textColor = FlatWhite()
        addCommentsTextField.textColor = FlatWhite()
        border.backgroundColor = FlatWhite()
        checklistStackView.tintColor = FlatWhite()
        activityIndicator.tintColor = FlatWhite()
        activityIndicator.hidesWhenStopped = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CommentsViewController.delegate.commentsWillDisappear(tableView.numberOfRows(inSection: 0))
    }

    @IBAction func checkButtonPressed(_ sender: UIButton) {
        if addCommentsTextField.text != "" {
            guard let curUser = Auth.auth().currentUser?.email else {fatalError()}
            db.collection("Users").document(CommentsViewController.user).collection("Posts").document(CommentsViewController.post).collection("Comments").document("Comment \(UUID.init().uuidString)").setData(["user":curUser, "comment":addCommentsTextField.text])
            addCommentsTextField.text = ""
            loadComments()
        }
    }
    func loadComments(){
        activityIndicator.startAnimating()
        db.collection("Users").document(CommentsViewController.user).collection("Posts").document(CommentsViewController.post).collection("Comments").getDocuments { (shot, error) in
            if let e = error {
                print(e.localizedDescription)
            } else if let shot = shot{
                if shot.documents.count == 0 {self.activityIndicator.stopAnimating()}
                for document in shot.documents {
                    self.storage.child("Users").child(document.data()["user"] as! String).child("Profile Picture").child("Profile Picture.png").getData(maxSize: 4*1024*1024) { (data, error) in
                        if let e = error{
                            print(e.localizedDescription)
                        } else if let data = data {
                            self.db.collection("Users").document(document.data()["user"] as! String).collection("Profile Information").document("Username").getDocument { (doc, error) in
                                if let e = error {
                                    print(e.localizedDescription)
                                } else if let doc = doc {
                                    self.comments[document.documentID ] = [document.data()["comment"] as! String:[UIImage(data: data)!, doc.data()!["username"]]]
                                    if self.comments.count == shot.documents.count {
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                            self.activityIndicator.stopAnimating()
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
    
}
extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print(comments)
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentsTableViewCell
        cell.usernameLabel.text = nil
        cell.usernameLabel.textColor = FlatWhite()
        cell.comment.text = nil
        cell.profilePic.image = nil
        cell.comment.textColor = FlatWhite()
        let key = [String] (comments.keys) [indexPath.row]
        let dict =  comments[key]
        let comment = [String] (dict!.keys) [0]
        cell.comment.text = comment
        cell.profilePic.image = dict![comment]! [0] as? UIImage
        cell.usernameLabel.text = dict![comment]! [1] as? String
        var newframe = cell.bgView.frame
        newframe.size.width = tableView.frame.size.width
        cell.bgView.frame = newframe
        cell.bgView.backgroundColor = GradientColor(.leftToRight, frame: cell.bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        
        return cell
    }
    
    
}
