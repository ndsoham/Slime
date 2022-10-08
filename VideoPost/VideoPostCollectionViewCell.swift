//
//  VideoPostCollectionViewCell.swift
//  Slime
//
//  Created by Soham Nagawanshi on 2/12/21.
//

import UIKit
import ChameleonFramework
protocol videoPostDelegate {
    func likeButtonPressed(tag: Int, button: UIButton)
    func commentButtonPressed(button: UIButton, tag: Int)
    func saveButtonPressed(button: UIButton)
    func shareButtonPressed(button: UIButton)
}
class VideoPostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var iconStackView: UIStackView!
    @IBOutlet weak var dockStackView: UIStackView!
    static var delegate: videoPostDelegate!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var videoView: AVPlayerView!
    @IBOutlet weak var bgView: UIView!
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
        videoView.addGestureRecognizer(gesture)
        videoView.isUserInteractionEnabled = true
    }
@objc func gestureRecognized(_ gesture: UITapGestureRecognizer) {
       buttonPressed(likeButton)
    }
@IBAction func buttonPressed(_ sender: UIButton) {
        if sender == likeButton {
            VideoPostCollectionViewCell.delegate.likeButtonPressed(tag: self.tag, button: sender)
        }
    if sender == commentButton {
        VideoPostCollectionViewCell.delegate.commentButtonPressed(button: sender, tag: self.tag)
    }

}
}
