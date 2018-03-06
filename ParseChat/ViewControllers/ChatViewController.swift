//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Henry Vuong on 3/3/18.
//  Copyright © 2018 Henry Vuong. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController, UITableViewDataSource {
    
    var messages: [String] = []
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func sendButton(_ sender: Any) {
        if messageTextField.text != "" {
            let chatMessage = PFObject(className: "Message")
            chatMessage["text"] = messageTextField.text ?? ""
            chatMessage["sender"] = PFUser.current()?.value(forKey: "username")
            
            chatMessage.saveInBackground { (success, error) in
                if success {
                    print("The message was saved!")
                    self.messageTextField.text = ""
                } else if let error = error {
                    print("Problem saving message: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOutInBackground { (error: Error?) in
            // PFUser.current() will now be nil
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        // Parse query
        var query = PFQuery(className:"Message")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for message in objects {
                        self.messages.append(message.value(forKey: "objectId") as! String)
                        self.tableView.reloadData()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        var query = PFQuery(className: "Message")
        query.getObjectInBackground(withId: "\(messages[indexPath.row])") {
            (message: PFObject?, error: Error?) -> Void in
            if error == nil && message != nil {
                cell.messageLabel.text = message?.value(forKey: "text") as! String
                cell.usernameLabel.text = message?.value(forKey: "sender") as! String
            } else {
                print(error)
            }
        }

        return cell
    }
    
    // timer
    @objc func onTimer() {
        // Parse query and add message objects that have not been added
        var query = PFQuery(className:"Message")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {                    for message in objects {
                        // checks if message is already in array
                        if !(self.messages.contains(message.value(forKey: "objectId") as! String)) {
                            self.messages.insert(message.value(forKey: "objectId") as! String, at: 0)
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
    }


}
