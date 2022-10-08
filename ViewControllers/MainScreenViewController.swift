//
//  MainScreenViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 1/21/21.
//

import UIKit
import ChameleonFramework
import AVFoundation
import AVKit
import Firebase
class MainScreenViewController: UIViewController {
  
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newPostButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var homepageButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var navigationControlDock: UIView!
    private let imagePicker = UIImagePickerController()
    private var data: [String] = []
    private var data2: [String] = []
    private var following:[String] = []
    private var posts:[String:[String]] = [:]
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var cellNumber: Int!
    override func viewDidLoad() {
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        loadFriends()
        super.viewDidLoad()
        navigationControlDock.backgroundColor = GradientColor(.leftToRight, frame: navigationControlDock.bounds, colors: [FlatGreen(), FlatBlue()])
        navBar.backgroundColor = GradientColor(.leftToRight, frame: navBar.bounds, colors: [FlatGreen(), FlatBlue()])
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
        chatButton.tintColor = FlatWhite()
        settingsButton.tintColor = FlatWhite()
        homepageButton.tintColor = FlatWhite()
        addFriendsButton.tintColor = FlatWhite()
        headerLabel.textColor = FlatWhite()
        newPostButton.tintColor = FlatWhite()
        bgView.backgroundColor = GradientColor(.leftToRight, frame: bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        navBar.layer.borderWidth = 0.5
        navBar.layer.borderColor = FlatBlack().cgColor
        navigationControlDock.layer.borderWidth = 0.5
        navigationControlDock.layer.borderColor = FlatBlack().cgColor
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.movie", "public.image"]
        PhotoPostCollectionViewCell.delegate = self
        VideoPostCollectionViewCell.delegate = self
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(userSwiped(with:)))
        gesture.direction = .up
        bgView.addGestureRecognizer(gesture)
        CommentsViewController.delegate = self

    }
    @objc func userSwiped(with: UISwipeGestureRecognizer) {
        navigationControlDock.isHidden = !navigationControlDock.isHidden
    }
    @IBAction func newPostButtonPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    func loadFriends() {
       
        guard let username = Auth.auth().currentUser?.email else {fatalError("no user logged in")}
        let folRef = db.collection("Users").document(username).collection("Profile Information").document("Friends").collection("Following")
        folRef.getDocuments { (shot, error) in
            if let e = error{
                print(e.localizedDescription)
            } else if let snapshot = shot{
                 self.following = []
                for document in snapshot.documents {
                    //print(document.documentID)
                    self.following.append(document.documentID)
                    self.loadPosts()

                }
                //print(self.following)
            }
        }
   
    }
    func loadPosts(){
        for friend in following {
            self.posts = [:]
            let posRef = db.collection("Users").document(friend).collection("Posts")
            posRef.order(by: "date", descending: true).getDocuments { (shot, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else if let snapshot = shot {
                    
                    for document in snapshot.documents {
                        self.db.collection("Users").document(friend).collection("Profile Information").document("Username").getDocument { (doc, error) in
                            if let e = error {
                                print(e.localizedDescription)
                            } else if let doc = doc {
                                
                                self.db.collection("Users").document(friend).collection("Posts").document(document.documentID).collection("Comments").getDocuments { (shot, error) in
                                    if let e = error{
                                        print(e.localizedDescription)
                                    } else if let shot = shot{
                                        print(shot.documents)
                                        self.posts[document.documentID] = [document.data()["type"] as! String, document.reference.parent.parent!.documentID, doc.data()!["username"] as! String,"\(shot.documents.count)"]
                                        //self.following[friend] = self.posts
                                        DispatchQueue.main.async {
                                            self.collectionView.reloadData()
                                        }
                                    }
                                }
                                
                                
                            }
                        }
                        
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
}
extension MainScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print(posts.keys.count)
//        print(posts)
        return posts.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("Data' \(data)")
//        print("Data 2: \(data2)")
//        print("Posts: \(posts)")
        let key = [String] (posts.keys) [indexPath.row]
        let arr = posts[key]
        let type = arr![0]
        if type == "image"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPostCollectionViewCell", for: indexPath) as! PhotoPostCollectionViewCell
            cell.bgView.backgroundColor = GradientColor(.leftToRight, frame: cell.bgView.bounds, colors: [FlatGreen(), FlatBlue()])
            cell.photoView.image = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            let key = [String] (posts.keys) [indexPath.row]
            let arr = posts[key]
            let username = arr![1]
            cell.usernameLabel.text = arr![2]
            cell.commentCountLabel.text = nil
            cell.commentCountLabel.text = arr![3]
          //  guard let username = Auth.auth().currentUser?.email else {fatalError()}
            storage.reference().child("Users").child(username).child("Posts").child([String] (posts.keys)[indexPath.row]).getData(maxSize: 4*1024*1024) { (data, error) in
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
                        self.db.collection("Users").document(username).collection("Posts").document([String](self.posts.keys)[indexPath.row]).collection("Liked By").getDocuments { (shot, error) in
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
            let key = [String] (posts.keys) [indexPath.row]
            let arr = posts[key]
            let username = arr![1]
            cell.usernameLabel.text = arr![2]
            cell.videoView.playerLayer.player = nil
            cell.commentCountLabel.text = nil
            cell.commentCountLabel.text = arr![3]
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            storage.reference().child("Users").child(username).child("Posts").child([String] (posts.keys)[indexPath.row]).downloadURL { (downloadUrl, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else if let url = downloadUrl {
                    let avPlayer = AVPlayer(url: url)
                    cell.videoView.playerLayer.player = avPlayer
                    cell.activityIndicator.stopAnimating()
                    cell.tag = indexPath.row
                    DispatchQueue.main.async {
                        self.db.collection("Users").document(username).collection("Posts").document([String](self.posts.keys)[indexPath.row]).collection("Liked By").getDocuments { (shot, error) in
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
       // return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = [String] (posts.keys) [indexPath.row]
        let arr = posts[key]
        let type = arr![0]
        if type == "video" {
            let cell = collectionView.cellForItem(at: indexPath) as! VideoPostCollectionViewCell
            if cell.videoView.player?.rate != 0 && cell.videoView.player?.error == nil  {
                cell.videoView.player?.pause()
            } else {
                cell.videoView.player?.play()
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width  , height: collectionView.frame.height )
    }
    

    
   
    
    
}

extension MainScreenViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[UIImagePickerController.InfoKey.mediaType] as! String == "public.image" {
            if let postImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage? {
                guard let metaData = postImage.pngData() else {
                    fatalError("failed to get the data")
                }
                let uploadMetaData = StorageMetadata.init()
                uploadMetaData.contentType = "image/png"
                if let username = Auth.auth().currentUser?.email {
                    let randomId = UUID.init().uuidString
                    let prog = storage.reference().child("Users").child(username).child("Posts").child("Post \(randomId)").putData(metaData, metadata: uploadMetaData)
                    db.collection("Users").document(username).collection("Posts").document("Post \(randomId)").setData(["identifier" : "\(randomId)", "type" : "image", "date":Date()])
                    prog.observe(.progress) { (snapshot) in
                        guard let pcThere = snapshot.progress?.fractionCompleted else {return}
                        if pcThere == 1.0 {
                            self.imagePicker.dismiss(animated: true, completion: nil)
                            self.loadPosts()
                            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                    }
                }

            }
        }
        else if info[UIImagePickerController.InfoKey.mediaType] as! String == "public.movie" {
            imagePicker.dismiss(animated: true, completion: nil)
            if let postVideo = info[.mediaURL]{
                var data = Data()
                do{
                     data = try Data(contentsOf: postVideo as! URL)
                    
                } catch {
                    print(error.localizedDescription)
                }
                
                let uploadMetaData = StorageMetadata.init()
                uploadMetaData.contentType = "video/mp4"
                if let username = Auth.auth().currentUser?.email {
                    let randomId = UUID.init().uuidString
                  let prog = storage.reference().child("Users").child(username).child("Posts").child("Post \(randomId)").putData(data, metadata: uploadMetaData)
                    db.collection("Users").document(username).collection("Posts").document("Post \(randomId)").setData(["identifier" : "\(randomId)", "type": "video", "date": Date()])
                    prog.observe(.progress) { (snapshot) in
                        guard let pcThere = snapshot.progress?.fractionCompleted else {return}
                        if pcThere == 1.0 {
                            self.imagePicker.dismiss(animated: true, completion: nil)
                            self.loadPosts()
                            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

                        }
                    }
                    
                }
            }
           
            
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension MainScreenViewController: photoPostDelegate, videoPostDelegate {
    func likeButtonPressed(tag: Int, button: UIButton) {
        let post = [String] (posts.keys) [tag]
        let username = posts[post]![1]
        let cell = collectionView.cellForItem(at: IndexPath(row: tag, section: 0)) as! VideoPostCollectionViewCell
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
        let post = [String] (posts.keys) [tag]
        let username = posts[post]![1]
        CommentsViewController.post = post
        CommentsViewController.user = username
        cellNumber = tag
        performSegue(withIdentifier: "goToComments", sender: self)

    }
    
    func saveButtonPressed(button: UIButton) {
        
    }
    
    func shareButtonPressed(button: UIButton) {
        
    }
    // - photos
    func photoLikeButtonPressed(tag: Int, button: UIButton) {
        let post = [String] (posts.keys) [tag]
        let username = posts[post]![1]
        let cell = collectionView.cellForItem(at: IndexPath(row: tag, section: 0)) as! PhotoPostCollectionViewCell
        db.collection("Users").document(username).collection("Posts").document(post).collection("Liked By").getDocuments { (shot, error) in
            if let e = error {
                print(e.localizedDescription)
            } else if let snapshot = shot {
               //print("im here")
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
        let post = [String] (posts.keys) [tag]
        let username = posts[post]![1]
        CommentsViewController.post = post
        CommentsViewController.user = username
        cellNumber = tag
        performSegue(withIdentifier: "goToComments", sender: self)
    }
    
    func photoSaveButtonPressed(button: UIButton) {
        
    }
    
    func photoShareButtonPressed(button: UIButton) {
        
    }
    

    
    
}
extension MainScreenViewController: commentsViewControllerDelegate {
    func commentsWillDisappear(_ comments: Int) {
        if collectionView.cellForItem(at: IndexPath(row: cellNumber, section: 0)) is VideoPostCollectionViewCell {
            let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! VideoPostCollectionViewCell
            cell.commentCountLabel.text = "\(comments)"
        }
        else {
            let cell = collectionView.cellForItem(at: IndexPath(row:cellNumber, section: 0)) as! PhotoPostCollectionViewCell
            cell.commentCountLabel.text = "\(comments)"
            
        }
    }
    
    
    
    
}
