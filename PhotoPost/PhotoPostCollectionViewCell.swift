//
//  PhotoPostCollectionViewCell.swift
//  Slime
//
//  Created by Soham Nagawanshi on 3/7/21.
//

import UIKit
import ChameleonFramework
protocol photoPostDelegate {
    func photoLikeButtonPressed(tag: Int, button: UIButton)
    func photoCommentButtonPressed(button: UIButton, tag: Int)
    func photoSaveButtonPressed(button: UIButton)
    func photoShareButtonPressed(button: UIButton)
}

class PhotoPostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    static var delegate: photoPostDelegate!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconStackView: UIStackView!
    @IBOutlet weak var dockStackView: UIStackView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.tintColor = FlatWhite()
        saveButton.tintColor = FlatWhite()
        commentButton.tintColor = FlatWhite()
        likeButton.tintColor = FlatWhite()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(gestureRecognized(_:)))
        gesture.numberOfTapsRequired = 2
        photoView.addGestureRecognizer(gesture)
        photoView.isUserInteractionEnabled = true
    }
    @objc func gestureRecognized(_ gesture: UITapGestureRecognizer){
       buttonPressed(likeButton)
    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender == likeButton {
            PhotoPostCollectionViewCell.delegate.photoLikeButtonPressed(tag: self.tag, button: sender)
        }
        if sender == commentButton {
            PhotoPostCollectionViewCell.delegate.photoCommentButtonPressed(button: sender, tag: self.tag)
        }
    }
}
