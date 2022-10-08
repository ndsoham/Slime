//
//  ChatTableViewCell.swift
//  Slime
//
//  Created by Soham Nagawanshi on 4/12/21.
//

import UIKit
import ChameleonFramework
class ChatTableViewCell: UITableViewCell {


    @IBOutlet weak var bubbleContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubble: UIView!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        bubble.layer.cornerRadius = 10
        bubble.layer.borderWidth = 0.5
        bubble.layer.borderColor = FlatWhite().cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
