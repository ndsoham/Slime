//
//  HomePagePostCollectionViewCell.swift
//  Slime
//
//  Created by Soham Nagawanshi on 3/3/21.
//

import UIKit
import ChameleonFramework
protocol deleteDelegate {
    func deleteButtonPressed(with: UIButton, tag: Int)
}
class HomePagePostCollectionViewCell: UICollectionViewCell {
    static var deleteDelegate: deleteDelegate!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        image.addGestureRecognizer(gesture2)
        image.addGestureRecognizer(gesture)
        image.isUserInteractionEnabled = true
        deleteButton.tintColor = FlatWhite()
    }
    @objc func longPressed(_ gesture: UILongPressGestureRecognizer){
        deleteButton.isHidden = false
        animate()
    
    }
    @objc func viewTapped(_ gesture: UITapGestureRecognizer){
        deleteButton.isHidden = true
        image.layer.removeAllAnimations()
    }
    func animate() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 0.07
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.toValue = NSNumber(value: -Double.pi/60)
        animation.fromValue = NSNumber(value: Double.pi/60)
        image.layer.add(animation, forKey: "iconShake")
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        HomePagePostCollectionViewCell.deleteDelegate.deleteButtonPressed(with: sender, tag: self.tag)
    }
    
}
