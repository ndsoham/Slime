//
//  PostViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 5/3/21.
//

import UIKit
import Firebase
import ChameleonFramework
import AVFoundation
class PostViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet var bgView: UIView!
    static var post:[String:[String]] = [:]
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "VideoPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoPostCollectionViewCell")
        collectionView.register(UINib(nibName: "PhotoPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoPostCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0.5
        }
        collectionView.layer.borderWidth = 0.5
        collectionView.layer.borderColor = FlatBlack().cgColor
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .black
        navBarView.backgroundColor = GradientColor(.leftToRight, frame: navBarView.bounds, colors: [FlatGreen(), FlatBlue()])
        PhotoPostCollectionViewCell.delegate = self
        VideoPostCollectionViewCell.delegate = self
        CommentsViewController.delegate = self
    }
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
        let key = [String] (PostViewController.post.keys) [indexPath.row]
        let arr = PostViewController.post[key]
        let type = arr![0]
        if type == "image"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPostCollectionViewCell", for: indexPath) as! PhotoPostCollectionViewCell
            cell.bgView.backgroundColor = GradientColor(.leftToRight, frame: cell.bgView.bounds, colors: [FlatGreen(), FlatBlue()])
            cell.photoView.image = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            let key = [String] (PostViewController.post.keys) [indexPath.row]
            let arr = PostViewController.post[key]
            let username = arr![1]
            cell.commentCountLabel.text = nil
            cell.commentCountLabel.text = arr![2]
            cell.usernameLabel.text = "Test.Friend.1"
            storage.reference().child("Users").child(username).child("Posts").child([String] (PostViewController.post.keys)[indexPath.row]).getData(maxSize: 4*1024*1024) { (data, error) in
                if let e = error {
                    print(" line 101 \(e.localizedDescription)")
                } else if let data = data {
                    let post = UIImage(data: data)
                    cell.photoView.image = post
                    cell.activityIndicator.stopAnimating()
                    cell.photoView.layer.borderWidth = 0.5
                    cell.photoView.layer.borderColor = FlatWhite().cgColor
                    cell.tag = indexPath.row
                    DispatchQueue.main.async {
                        self.db.collection("Users").document(username).collection("Posts").document([String](PostViewController.post.keys)[indexPath.row]).collection("Liked By").getDocuments { (shot, error) in
                            if let e = error {
                                print(e.localizedDescription)
                            } else if let shot = shot {
                                cell.likeCountLabel.text = "\(shot.documents.count)"
                                for document in shot.documents {
                                    if document.documentID == Auth.auth().currentUser?.email {
                                        let lb = UIImage(systemName: "heart.fill")
                                        cell.likeButton.setBackgroundImage(lb, for: .normal)
                                        cell.likeButton.tintColor = FlatRed()
                                    }
                                }
                                cell.dockStackView.isHidden = false
                            }
                        }
                    }
                    
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPostCollectionViewCell", for: indexPath) as! VideoPostCollectionViewCell
            let key = [String] (PostViewController.post.keys) [indexPath.row]
            let arr = PostViewController.post[key]
            let username = arr![1]
            cell.videoView.playerLayer.player = nil
            cell.commentCountLabel.text = nil
            cell.commentCountLabel.text = arr![2]
            cell.usernameLabel.text = "Test.Friend.1"
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            storage.reference().child("Users").child(username).child("Posts").child([String] (PostViewController.post.keys)[indexPath.row]).downloadURL { (downloadUrl, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else if let url = downloadUrl {
                    let avPlayer = AVPlayer(url: url)
                    cell.videoView.playerLayer.player = avPlayer
                    cell.activityIndicator.stopAnimating()
                    cell.tag = indexPath.row
                    DispatchQueue.main.async {
                        self.db.collection("Users").document(username).collection("Posts").document([String](PostViewController.post.keys)[indexPath.row]).collection("Liked By").getDocuments { (shot, error) in
                            if let e = error {
                                print(e.localizedDescription)
                            } else if let shot = shot {
                                cell.likeCountLabel.text = "\(shot.documents.count)"
                                for document in shot.documents {
                                    if document.documentID == Auth.auth().currentUser?.email {
                                        let lb = UIImage(systemName: "heart.fill")
                                        cell.likeButton.setBackgroundImage(lb, for: .normal)
                                        cell.likeButton.tintColor = FlatRed()
                                    }
                                }
                                cell.dockStackView.isHidden = false
                                
                            }
                        }
                    }
                }
            }
            return cell
        }
    }
    
    
}
extension PostViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
extension PostViewController: photoPostDelegate, videoPostDelegate {
    func photoLikeButtonPressed(tag: Int, button: UIButton) {
        let post = [String] (PostViewController.post.keys) [0]
        let username = PostViewController.post[post]![1]
        let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! PhotoPostCollectionViewCell
        db.collection("Users").document(username).collection("Posts").document(post).collection("Liked By").getDocuments { (shot, error) in
            if let e = error {
                print(e.localizedDescription)
            } else if let snapshot = shot {
                
                guard let curUser = Auth.auth().currentUser?.email else {fatalError()}
                for document in snapshot.documents {
                    if document.documentID == curUser {
                        self.db.collection("Users").document(username).collection("Posts").document(post).collection("Liked By").document(curUser).delete()
                        let lb = UIImage(systemName: "heart")
                        button.setBackgroundImage(lb, for: .normal)
                        button.tintColor = FlatWhite()
                        let likes = Int(cell.likeCountLabel.text!)
                        DispatchQueue.main.async {
                            cell.likeCountLabel.text = "\(likes!-1)"
                        }
                        return
                        
                    }
                }
                self.db.collection("Users").document(username).collection("Posts").document(post).collection("Liked By").document(curUser).setData(["Liked" : true])
                let lb = UIImage(systemName: "heart.fill")
                button.setBackgroundImage(lb, for: .normal)
                button.tintColor = FlatRed()
                let likes = Int(cell.likeCountLabel.text!)
                DispatchQueue.main.async {
                    cell.likeCountLabel.text = "\(likes!+1)"
                }
            }
        }
        
    }
    
    func photoCommentButtonPressed(button: UIButton, tag: Int) {
        let post = [String] (PostViewController.post.keys) [0]
        let username = PostViewController.post[post]![1]
        CommentsViewController.post = post
        CommentsViewController.user = username
        performSegue(withIdentifier: "goToComments", sender: self)
    }
    
    func photoSaveButtonPressed(button: UIButton) {
        
    }
    
    func photoShareButtonPressed(button: UIButton) {
        
    }
    
    func likeButtonPressed(tag: Int, button: UIButton) {
        let post = [String] (PostViewController.post.keys) [0]
        let username = PostViewController.post[post]![1]
        let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! VideoPostCollectionViewCell
        db.collection("Users").document(username).collection("Posts").document(post).collection("Liked By").getDocuments { (shot, error) in
            if let e = error {
                print(e.localizedDescription)
            } else if let snapshot = shot {
                guard let curUser = Auth.auth().currentUser?.email else {fatalError()}
                for document in snapshot.documents {
                    if document.documentID == curUser {
                        self.db.collection("Users").document(username).collection("Posts").document(post).collection("Liked By").document(curUser).delete()
                        let lb = UIImage(systemName: "heart")
                        button.setBackgroundImage(lb, for: .normal)
                        button.tintColor = FlatWhite()
                        let likes = Int(cell.likeCountLabel.text!)
                        DispatchQueue.main.async {
                            cell.likeCountLabel.text = "\(likes!-1)"
                        }
                        return
                        
                    }
                }
                self.db.collection("Users").document(username).collection("Posts").document(post).collection("Liked By").document(curUser).setData(["Liked" : true])
                let lb = UIImage(systemName: "heart.fill")
                button.setBackgroundImage(lb, for: .normal)
                button.tintColor = FlatRed()
                let likes = Int(cell.likeCountLabel.text!)
                DispatchQueue.main.async {
                    cell.likeCountLabel.text = "\(likes!+1)"
                }
                
            }
        }
    }
    
    func commentButtonPressed(button: UIButton, tag: Int) {
        let post = [String] (PostViewController.post.keys) [0]
        let username = PostViewController.post[post]![1]
        CommentsViewController.post = post
        CommentsViewController.user = username
        performSegue(withIdentifier: "goToComments", sender: self)
    }
    
    func saveButtonPressed(button: UIButton) {
        
    }
    
    func shareButtonPressed(button: UIButton) {
        
    }
    
    
}
extension PostViewController: commentsViewControllerDelegate {
    func commentsWillDisappear(_ comments: Int) {
        if collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) is VideoPostCollectionViewCell {
            let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! VideoPostCollectionViewCell
            cell.commentCountLabel.text = "\(comments)"
        }
        else {
            let cell = collectionView.cellForItem(at: IndexPath(row:0, section: 0)) as! PhotoPostCollectionViewCell
            cell.commentCountLabel.text = "\(comments)"
            
        }
    }
    
 
    
    
}
