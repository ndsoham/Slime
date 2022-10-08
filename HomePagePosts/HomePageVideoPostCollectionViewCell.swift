//
//  HomePageVideoPostCollectionViewCell.swift
//  Slime
//
//  Created by Soham Nagawanshi on 3/5/21.
//

import UIKit
import ChameleonFramework
protocol deleteVideoDelegate {
    func deleteVideoButtonPressed(with: UIButton, tag:Int)
}
class HomePageVideoPostCollectionViewCell: UICollectionViewCell {
    static var deleteVideoDelegate: deleteVideoDelegate!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var thumbnail: AVPlayerView!
    @IBOutlet weak var videoView: AVPlayerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        videoView.addGestureRecognizer(gesture2)
        videoView.addGestureRecognizer(gesture)
        videoView.isUserInteractionEnabled = true
        deleteButton.tintColor = FlatWhite()
    }
    @objc func longPressed(_ gesture: UILongPressGestureRecognizer){
        deleteButton.isHidden = false
       animate()
    

    }
    @objc func viewTapped(_ gesture: UITapGestureRecognizer){
        deleteButton.isHidden = true
        videoView.layer.removeAllAnimations()
    }
    func animate() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 0.07
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.toValue = NSNumber(value: -Double.pi/60)
        animation.fromValue = NSNumber(value: Double.pi/60)
        videoView.layer.add(animation, forKey: "iconShake")
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        HomePageVideoPostCollectionViewCell.deleteVideoDelegate.deleteVideoButtonPressed(with: sender, tag: self.tag)
    }
    
}
