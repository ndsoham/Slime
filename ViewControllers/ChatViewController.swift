//
//  ChatViewController.swift
//  Slime
//
//  Created by Soham Nagawanshi on 4/9/21.
//

import UIKit
import ChameleonFramework
class ChatViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var navBar: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "chatTableViewCell")
        tableView.register(UINib(nibName: "MeChatTableViewCell", bundle: nil), forCellReuseIdentifier: "meChatTableViewCell")
        tableView.tableFooterView = footerView
        tableView.dataSource = self
        messageTextField.layer.borderWidth = 0.5
        messageTextField.layer.borderColor = GradientColor(.leftToRight, frame: messageTextField.bounds, colors: [FlatGreen(), FlatBlue()]).cgColor
        navBar.backgroundColor = GradientColor(.leftToRight, frame: navBar.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.backgroundColor = GradientColor(.leftToRight, frame: tableView.bounds, colors: [FlatGreen(), FlatBlue()])
        footerView.backgroundColor = GradientColor(.leftToRight, frame: footerView.bounds, colors: [FlatGreen(), FlatBlue()])
        tableView.rowHeight = 67
        tableView.separatorStyle = .none
        doneButton.tintColor = FlatWhite()
        

    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row%2 == 0{
        let cell =  tableView.dequeueReusableCell(withIdentifier: "chatTableViewCell", for: indexPath) as! ChatTableViewCell
        var newFrame = cell.bgView.frame
        newFrame.size.width = tableView.frame.size.width
        cell.bgView.frame = newFrame
        cell.bgView.backgroundColor = GradientColor(.leftToRight, frame: cell.bgView.bounds, colors: [FlatGreen(), FlatBlue()])
            cell.bubble.backgroundColor = FlatBlue()
            cell.bubbleContainer.backgroundColor = .clear
        return cell
        
     }
        let cell =  tableView.dequeueReusableCell(withIdentifier: "meChatTableViewCell", for: indexPath) as! MeChatTableViewCell
        var newFrame = cell.bgView.frame
        newFrame.size.width = tableView.frame.size.width
        cell.bgView.frame = newFrame
        cell.bgView.backgroundColor = GradientColor(.leftToRight, frame: cell.bgView.bounds, colors: [FlatGreen(), FlatBlue()])
        cell.bubble.backgroundColor = FlatGreen()
        cell.bubbleContainer.backgroundColor = .clear

        return cell
    }
    
    
}
