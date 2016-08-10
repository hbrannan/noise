//
//  ChatScreenViewController.swift
//  noise
//
//  Created by Michael DLC on 8/9/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import UIKit


//configure chatScreenVC: in addition to its default class, (DS)the table code herein will provide info needed to construct table view.
//ALSO, (VD) declares the obj (ref) that will determine how to manage selections, configure section headings and footers, help to delete and reorder cells

class ChatScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //outlets defined
    
    @IBOutlet weak var chatScreenTable: UITableView!
    var messageCollection : [[String: String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //define dummy data

        let dummyDatum2 : [String: String] = ["userName": "MDLC", "createdAt": "2", "mssg": "yolo"]
        let dummyDatum3 : [String: String] = ["userName": "HB", "createdAt": "3", "mssg": "bro"]
        let dummyDatum4 : [String: String] = ["userName": "MDLC", "createdAt": "4", "mssg": "ohnono"]
        messageCollection.append(dummyDatum2)
        messageCollection.append(dummyDatum3)
        messageCollection.append(dummyDatum4)
        
        //sort messageCollection by createdAt
        
        
        //setup to display dummy data in table
        
            //define obj that acts as the data source for the tableView
            chatScreenTable.dataSource = self
        
           //define the obj that will act as the delegate for the tableView
           chatScreenTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageCollection.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = messageCollection[indexPath.row]["mssg"]
        return cell
    }

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
