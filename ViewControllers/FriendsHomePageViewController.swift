//
//  FriendsHomePageViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 3/22/21.
//

import UIKit
import ChameleonFramework
import Firebase
import AVFoundation
import AVKit

class FriendsHomePageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet var bgView: UIView!
    static var profilePic: UIImage!
    static var displayName: String!
    static var friend: String!
    private let db = Firestore.firestore()
    var posts: [String] = []
    var posts2: [String] = []
    override func viewDidLoad() {
        loadPosts()
        super.viewDidLoad()
        bgView.backgroundColor = GradientColor(.leftToRight, frame: bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        profilePicture.layer.borderColor = FlatWhite().cgColor
        profilePicture.layer.borderWidth = 1
        profilePicture.backgroundColor = FlatBlack()
        collectionView.register(UINib(nibName: "HomePagePhotoPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePagePhotoPostCollectionViewCell")
        collectionView.register(UINib(nibName: "HomePageVideoPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePageVideoPostCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 3
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "CollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "reusableView")
        CollectionReusableView.delegate = self
        displayNameTextField.text = FriendsHomePageViewController.displayName
        profilePicture.image = FriendsHomePageViewController.profilePic
        guard let username = Auth.auth().currentUser?.email else {fatalError("no user logged in")}
        db.collection("Users").document(username).collection("Profile Information").document("Friends").collection("Following").getDocuments { (shot, error) in
            if let e = error{
                print(e.localizedDescription)
            } else if let snapshot = shot{
                for document in snapshot.documents {
                    if document.documentID == FriendsHomePageViewController.friend {
                        self.followButton.isHidden = true
                    }
                }
            }
        }
        
    }
    func loadPosts() {
        let docRef2 = db.collection("Users").document(FriendsHomePageViewController.friend).collection("Posts")
        docRef2.order(by: "date", descending: true).getDocuments { (snapshot, error) in
            if let e = error{
                print(e.localizedDescription)
            } else{
                self.posts = []
                self.posts2 = []
                for document in snapshot!.documents {
                    self.posts.append(document.data()["type"] as! String)
                    self.posts2.append(document.documentID)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
   
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        var alrFriend = false
        guard let username = Auth.auth().currentUser?.email else {
            fatalError("user not logged in")
        }
        let docRef = db.collection("Users").document(username).collection("Profile Information").document("Friends").collection("Following")
        let docRef2 = db.collection("Users").document(FriendsHomePageViewController.friend).collection("Profile Information").document("Friends").collection("Followers")
        docRef.getDocuments { (shot, error) in
            if let e = error{
                print(e.localizedDescription)
            } else if let shot = shot{
                for document in shot.documents{
                    if document.documentID == FriendsHomePageViewController.friend {
                        alrFriend = true
                    }
                }
                if !alrFriend {
                    docRef.document(FriendsHomePageViewController.friend).setData(["Following" : true])
                    docRef2.document(username).setData(["Follower" : true])
                    self.followButton.isHidden = true
                }
            }
        }
    
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
       
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
extension FriendsHomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts[indexPath.row] == "image"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePagePhotoPostCollectionViewCell", for: indexPath) as! HomePagePostCollectionViewCell
            cell.layer.borderWidth = 1
            cell.layer.borderColor = FlatWhite().cgColor
            cell.image.image = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            Storage.storage().reference().child("Users").child(FriendsHomePageViewController.friend).child("Posts").child(self.posts2[indexPath.row]).getData(maxSize: 4*1024*1024) { (data, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else if let data = data {
                    let post = UIImage(data: data)
                    cell.image.image = post
                    cell.activityIndicator.stopAnimating()
                }
            }
            cell.contentView.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageVideoPostCollectionViewCell", for: indexPath) as! HomePageVideoPostCollectionViewCell
            cell.layer.borderWidth = 1
            cell.layer.borderColor = FlatWhite().cgColor
            cell.videoView.playerLayer.player = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            Storage.storage().reference().child("Users").child(FriendsHomePageViewController.friend).child("Posts").child(self.posts2[indexPath.row]).downloadURL { (downloadUrl, error) in
                if let e = error {
                    fatalError(e.localizedDescription)
                } else if let url = downloadUrl {
                    let avPlayer = AVPlayer(url: url)
                    cell.videoView.playerLayer.player = avPlayer
                    cell.activityIndicator.stopAnimating()
                }
            }
            cell.contentView.isUserInteractionEnabled = false
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width)/4 - 4, height: 135)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "reusableView", for: indexPath) as! CollectionReusableView
        view.bgView.backgroundColor = .clear
        view.followersButton.tintColor = FlatWhite()
        view.followingButton.tintColor = FlatWhite()
        return view
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // print("im here")
        PostViewController.post = [:]
        PostViewController.post[posts2[indexPath.row]] = [posts[indexPath.row], FriendsHomePageViewController.friend]
        db.collection("Users").document(FriendsHomePageViewController.friend).collection("Posts").document(posts2[indexPath.row]).collection("Comments").getDocuments { (shot, error) in
            if let e = error{
                print(e.localizedDescription)
            } else if let shot = shot {
                PostViewController.post = [:]
                PostViewController.post[self.posts2[indexPath.row]] = [self.posts[indexPath.row], FriendsHomePageViewController.friend, "\(shot.documents.count)"]
            }
            self.performSegue(withIdentifier: "goToPost", sender: self)
        }
       
    }
    
    
}
extension FriendsHomePageViewController: friendsDelegate {
    func buttonPressed(type: UIButton) {
        if type.currentTitle == "Followers" {
            FollowersFollowingViewController.friend = "Followers"
            FollowersFollowingViewController.curUser = FriendsHomePageViewController.friend
            performSegue(withIdentifier: "goToFriends", sender: self)
        }
        if type.currentTitle == "Following" {
            FollowersFollowingViewController.friend = "Following"
            FollowersFollowingViewController.curUser = FriendsHomePageViewController.friend
            performSegue(withIdentifier: "goToFriends", sender: self)
            
        }
    }
    
    
}
