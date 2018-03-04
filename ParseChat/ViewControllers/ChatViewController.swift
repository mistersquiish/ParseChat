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
    
    var messages: [NSObject] = []
    
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func sendButton(_ sender: Any) {
        if messageTextField.text != "" {
            let chatMessage = PFObject(className: "Message")
            chatMessage["text"] = messageTextField.text ?? ""
            
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        // Parse query
        var query = PFQuery(className:"Message")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for message in objects {
                        self.messages.append(message)
                        self.tableView.reloadData()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
        
        //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
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
        cell.messageLabel.text = messages[indexPath.row].value(forKey: "text") as? String
        
        return cell
    }
    
    // timer
    @objc func onTimer() {
        
    }


}
