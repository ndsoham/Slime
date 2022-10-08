//
//  HomePageViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 2/4/21.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseFirestore
import AVFoundation
import AVKit
class HomePageViewController: UIViewController {

   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var camerButton: UIButton!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet var bgView: UIView!
    var imagePicker = UIImagePickerController()
    private let db = Firestore.firestore()
    @IBOutlet weak var collectionView: UICollectionView!
    private var data: [String] = []
    private var data2: [String] = []
    var typeOfData = ""
    var dataFromTheThing = Data()
    override func viewDidLoad() {
        loadPosts()
        super.viewDidLoad()
        bgView.backgroundColor = GradientColor(.leftToRight, frame: bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        profilePicture.layer.borderColor = FlatWhite().cgColor
        profilePicture.layer.borderWidth = 1
        profilePicture.backgroundColor = FlatBlack()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        displayNameTextField.textColor = FlatWhite()
        camerButton.tintColor = FlatWhite()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        if let username = Auth.auth().currentUser?.email {
            let storage = Storage.storage().reference().child("Users").child(username).child("Profile Picture").child("Profile Picture.png")
            storage.getData(maxSize: 4*1024*1024) { (data, error) in
                if let e = error {
                    print("Error fething data\(e.localizedDescription)")
                    let image = #imageLiteral(resourceName: "Slime")
                    self.profilePicture.image = image
                    
                    return
                } else if let d = data {
                    DispatchQueue.main.async {
                        self.profilePicture.image = UIImage(data: d)
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
            let docRef = db.collection("Users").document(username).collection("Profile Information").document("Username")
            docRef.getDocument { (document, error) in
               
                if let doc = document, doc.exists {
                    if let docDic = doc.data(){
                        self.displayNameTextField.text = docDic["username"] as? String
                    }
                }
            }
            
            
            
            

//
        }
        collectionView.register(UINib(nibName: "HomePagePhotoPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePagePhotoPostCollectionViewCell")
        collectionView.register(UINib(nibName: "HomePageVideoPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePageVideoPostCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 2
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "CollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "reusableView")
        
        doneButton.tintColor = FlatWhite()
        CollectionReusableView.delegate = self
        HomePagePostCollectionViewCell.deleteDelegate = self
        HomePageVideoPostCollectionViewCell.deleteVideoDelegate = self
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if displayNameTextField.text != ""{
            guard let username = Auth.auth().currentUser?.email else {fatalError()}
            db.collection("Users").document(username).collection("Profile Information").document("Username").setData(["username" : displayNameTextField.text])
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    func loadPosts() {
        
        if let username = Auth.auth().currentUser?.email{
            let docRef2 = self.db.collection("Users").document(username).collection("Posts")
            docRef2.order(by: "date", descending: true).getDocuments { (snapshot, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    self.data = []
                    self.data2 = []
                    
                    for document in snapshot!.documents {
                        
                        self.data.append(document.data()["type"] as! String)
                        self.data2.append(document.documentID)
            
                        DispatchQueue.main.async{
                            self.collectionView.reloadData()
                        }
                    }
                    if snapshot?.documents.count == 0 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
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

extension HomePageViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage?{
            profilePicture.image = pickedImage
            imagePicker.dismiss(animated: true, completion: nil)
            guard let imageData = pickedImage.pngData() else {
                return
            }
            let uploadMetaData = StorageMetadata.init()
            uploadMetaData.contentType = "image/png"
            
            if let username = Auth.auth().currentUser?.email {
                let storage = Storage.storage().reference().child("Users").child(username).child("Profile Picture").child("Profile Picture.png")
                storage.putData(imageData, metadata: uploadMetaData) { (data, error) in
                    if let e = error {
                        print(e.localizedDescription)
                        return
                    } else {
                       // print("successfuly uploaded profile picture")
                    }
                }
                
                
            }
            
            }
    }
    
}

extension HomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if data[indexPath.row] == "image" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePagePhotoPostCollectionViewCell", for: indexPath) as! HomePagePostCollectionViewCell
            cell.tag = indexPath.row
            cell.layer.borderWidth = 1
            cell.layer.borderColor = FlatWhite().cgColor
            cell.image.image = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            cell.deleteButton.isHidden = true
            guard let username = Auth.auth().currentUser?.email else { fatalError()}
            Storage.storage().reference().child("Users").child(username).child("Posts").child(self.data2[indexPath.row]).getData(maxSize: 4*1024*1024) { (data, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else if let data = data {
                    let post = UIImage(data: data)
                    cell.image.image = post
                    cell.activityIndicator.stopAnimating()
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageVideoPostCollectionViewCell", for: indexPath) as! HomePageVideoPostCollectionViewCell
            cell.layer.borderWidth = 1
            cell.layer.borderColor = FlatWhite().cgColor
            cell.tag = indexPath.row
            cell.videoView.playerLayer.player = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            cell.deleteButton.isHidden = true
            guard let username = Auth.auth().currentUser?.email else {fatalError()}
            Storage.storage().reference().child("Users").child(username).child("Posts").child(self.data2[indexPath.row]).downloadURL { (downloadUrl, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else if let url = downloadUrl {
                    let avPlayer = AVPlayer(url: url)
                    cell.videoView.playerLayer.player = avPlayer
                    cell.activityIndicator.stopAnimating()
                }
            }
            return cell
        }
    } 
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width/4) - 4 , height: 135)
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
    
    
    
}

extension HomePageViewController: friendsDelegate {
    func buttonPressed(type: UIButton) {
        if type.currentTitle == "Followers" {
            FollowersFollowingViewController.friend = "Followers"
            guard let curUser = Auth.auth().currentUser?.email else {
                fatalError()
            }
            FollowersFollowingViewController.curUser = curUser
            performSegue(withIdentifier: "goToFriends", sender: self)
        }
        if type.currentTitle == "Following" {
            FollowersFollowingViewController.friend = "Following"
            guard let curUser = Auth.auth().currentUser?.email else {
                fatalError()
            }
            FollowersFollowingViewController.curUser = curUser
            performSegue(withIdentifier: "goToFriends", sender: self)

        }
    }
    
    
}
extension HomePageViewController: deleteDelegate, deleteVideoDelegate {
    func deleteButtonPressed(with: UIButton, tag: Int) {
        guard let username = Auth.auth().currentUser?.email else {fatalError()}
        db.collection("Users").document(username).collection("Posts").document(data2[tag]).delete()
        Storage.storage().reference().child("Users").child(username).child("Posts").child(data2[tag]).delete(completion: nil)
        loadPosts()
       
    }
    
    func deleteVideoButtonPressed(with: UIButton, tag: Int) {
        guard let username = Auth.auth().currentUser?.email else {fatalError()}
        db.collection("Users").document(username).collection("Posts").document(data2[tag]).delete()
        Storage.storage().reference().child("Users").child(username).child("Posts").child(data2[tag]).delete(completion: nil)
        loadPosts()
    }
    
    
    
   
    
    
}
