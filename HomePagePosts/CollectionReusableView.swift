//
//  CollectionReusableView.swift
//  Slime
//
//  Created by Soham Nagawanshi on 4/5/21.
//

import UIKit

protocol friendsDelegate {
    func buttonPressed(type: UIButton)
}

class CollectionReusableView: UICollectionReusableView {
  
    @IBOutlet weak var followersButton: UIButton!
    static var delegate: friendsDelegate!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        CollectionReusableView.delegate.buttonPressed(type: sender)
    }
    
}
