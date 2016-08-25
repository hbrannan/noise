import UIKit
import RealmSwift
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())

//    @IBOutlet weak var CollectionView: UICollectionView!
//    @IBOutlet weak var SendChatTextField: UITextField!
//    @IBOutlet weak var NavigationLabel: UINavigationItem!
//    @IBOutlet weak var MessageTextFieldLabel: UITextField!
    var messages = [JSQMessage]()
    
//    let realm = try! Realm()
    var friend = Friend()
//    var messages = List<Message>()
//    var newMessage = [String: AnyObject]()
    
    override func viewDidLoad() {
        title = self.friend.username
        super.viewDidLoad()
        self.setup()
        self.addDemoMessages()
        print("print friend", friend)
//        // configure states
//        self.CollectionView.dataSource = self
//        self.CollectionView.delegate = self
//        self.title = friend.firstname
//        updateChatScreen()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector (handleNewMessage), name: "newMessage", object: nil)
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
//
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.messages.count
//    }
 
//    func updateChatScreen() {
//        if realm.objects(Conversation).filter("friendID = \(friend.friendID) ").count == 0 {
//            try! realm.write{
//                let startNewConversation = Conversation()
//                startNewConversation.friendID = friend.friendID
//                realm.add(startNewConversation)
//            }
//        } else {
//            self.messages = realm.objects(Conversation).filter("friendID = \(friend.friendID)")[0].messages
//            self.CollectionView.reloadData()
//        }
//    }

//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        // tell the controller to use the reusuable 'receivecell' controlled by chatCollectionViewCell
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ChatCell",
//            forIndexPath: indexPath) as! ChatCollectionViewCell
//        
//        let message = self.messages[indexPath.row]
//        
//        if  message.sourceID == friend.friendID {
//            cell.receiveChatLabel.layer.cornerRadius = 5
//            cell.receiveChatLabel.layer.masksToBounds = true
//            cell.receiveChatLabel.clipsToBounds = true
//            cell.receiveChatLabel.text = self.messages[indexPath.row].body
//            cell.sendChatLabel.hidden = true
//            return cell
//        } else {
//            cell.sendChatLabel.layer.cornerRadius = 5
//            cell.sendChatLabel.layer.masksToBounds = true
//            cell.sendChatLabel.clipsToBounds = true
//            cell.sendChatLabel.text = self.messages[indexPath.row].body
//            cell.receiveChatLabel.hidden = true
//            return cell
//        }
//    }
 
//    @IBAction func sendButtonTapped(sender: AnyObject) {
//        self.newMessage = [
//            "sourceID" : realm.objects(User)[0].userID,
//            "targetID" : self.friend.friendID,
//            "body"     : self.SendChatTextField.text!
//        ]
//        // future refactor: consider immediate persistence (w/o waiting for the server to return) to improve UX
//        SocketIOManager.sharedInstance.sendEncryptedChat(newMessage)
//    }
    
//    @objc func handleNewMessage(notification: NSNotification) -> Void {
//        
//        let userInfo = notification.userInfo!
//        let sourceID = userInfo["sourceID"] as? Int
//        
//        let message = Message()
//        
//        if (sourceID != nil) {
//            // reciever
//            if (sourceID == self.friend.friendID) {
//                message.sourceID = sourceID!
//                message.targetID = userInfo["targetID"] as! Int
//                message.body = userInfo["body"] as! String
//                message.messageID = Int((userInfo["messageID"] as! NSString).doubleValue)
//                message.createdAt = userInfo["createdAt"] as! Int
//            } else {
//                return
//            }
//        } else {
//            // sender
//            message.sourceID = self.newMessage["sourceID"] as! Int
//            message.targetID = self.newMessage["targetID"] as! Int
//            message.body = self.newMessage["body"] as! String
//            message.messageID = Int(userInfo["messageID"] as! String)!
//            message.createdAt = userInfo["createdAt"] as! Int
//        }
//        
//        try! realm.write{
//            let conversationHistory = realm.objects(Conversation).filter("friendID = \(self.friend.friendID)")[0]
//            conversationHistory.largestMessageID = message.messageID
//            conversationHistory.messages.append(message)
//            print("successfuly append \(message) in history", conversationHistory)
//            // TODO: optimize such that only new message is loaded.
// //           updateChatScreen()
//        }
//        
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
  }


extension ChatViewController {
    
    func addDemoMessages() {
        for i in 1...10 {
            let sender = (i%2 == 0) ? "Server" : self.senderId
            let messageContent = "Message nr. \(i)"
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessagesView()
    }
    
    func setup() {
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
}

extension ChatViewController  {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
//        self.messages.removeAtIndex(indexPath.row)
//    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}


