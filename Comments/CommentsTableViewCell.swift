//
//  CommentsTableViewCell.swift
//  Slime
//
//  Created by Soham Nagawanshi on 4/7/21.
//

import UIKit
import ChameleonFramework
class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.layer.borderWidth = 1
        profilePic.layer.borderColor = FlatBlack().cgColor
        bgView.backgroundColor = GradientColor(.leftToRight, frame: bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        profilePic.backgroundColor = FlatBlack()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
