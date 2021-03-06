import UIKit
import RealmSwift
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    let realm = try! Realm()
    var messagesFromRealm = List<Message>()
    var messages = [JSQMessage]()
    var newMessage = [String: AnyObject]()
    var friend = Friend()
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
        self.updateChatScreen()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector (handleNewMessage), name: "newMessage", object: nil)
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
}

//Navigation methods
extension ChatViewController {
    
    func setup() {
        self.title = self.friend.username
        self.senderId = String(realm.objects(User)[0].userID)   //UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        
        let friendInfoButton = UIBarButtonItem(title: "info", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(friendInfoButtonTapped))
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    
        self.navigationItem.rightBarButtonItem = friendInfoButton
        self.navigationItem.leftBarButtonItem = backButton
        
        //chatbubble
        
        self.incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        self.outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        
    }
    
    func friendInfoButtonTapped() -> Void {
        let friendInfoViewController = FriendInfoViewController()
        friendInfoViewController.friendInfo = self.friend
        self.presentViewController(UINavigationController(rootViewController: friendInfoViewController), animated: false, completion: nil)
    }
    
    func backButtonTapped() {
        self.dismissViewControllerAnimated(false, completion: nil)
        
        //self.presentViewController(UINavigationController(rootViewController: FriendsListViewController()), animated: true, completion: nil)
        //let layout = UICollectionViewFlowLayout()
        //let recentChatsController = RecentChatsViewController(collectionViewLayout: layout)
        //self.presentViewController(UINavigationController(rootViewController: recentChatsController), animated: true, completion: nil)
    }
    
    func updateChatScreen() {
        if realm.objects(Conversation).filter("friendID = \(friend.friendID) ").count == 0 {
            print("-----ERROR: SEGUED TO CHAT SCREEN W/O INSTANTIATING CHAT OBJECT------")
        } else {
            self.messagesFromRealm = realm.objects(Conversation).filter("friendID = \(friend.friendID)")[0].messages
            for realmMessage in self.messagesFromRealm {
                let message = JSQMessage(senderId: String(realmMessage.sourceID), displayName: "sender display name", text: realmMessage.body)
                self.messages += [message]
            }
            self.reloadMessagesView()
        }
    }
    
    @objc func handleNewMessage(notification: NSNotification) -> Void {
        let userInfo = notification.userInfo!
        let sourceID = userInfo["sourceID"] as? Int
        let message = Message()
        
        if (sourceID != nil) {
            // reciever
            if (sourceID == self.friend.friendID) {
                message.sourceID = sourceID!
                message.targetID = userInfo["targetID"] as! Int
                message.body = userInfo["body"] as! String
                message.messageID = Int((userInfo["messageID"] as! NSString).doubleValue)
                message.createdAt = userInfo["createdAt"] as! Int
            } else {
                return
            }
        } else {
            // sender
            message.sourceID = self.newMessage["sourceID"] as! Int
            message.targetID = self.newMessage["targetID"] as! Int
            message.body = self.newMessage["body"] as! String
            message.messageID = Int(userInfo["messageID"] as! String)!
            message.createdAt = userInfo["createdAt"] as! Int
        }
        
        try! realm.write{
            let conversationHistory = realm.objects(Conversation).filter("friendID = \(self.friend.friendID)")[0]
            conversationHistory.largestMessageID = message.messageID
            conversationHistory.messages.append(message)
            print("successfuly append \(message) in history", conversationHistory)
            // TODO: optimize such that only new message is loaded.
            updateChatScreen()
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

//UI Configurations
extension ChatViewController  {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = self.messages[indexPath.row]
        
        if Int(data.senderId) == self.friend.friendID {
            return self.incomingBubble
        } else {
            return self.outgoingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

extension ChatViewController {

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.newMessage = [
            "sourceID" : realm.objects(User)[0].userID,
            "targetID" : self.friend.friendID,
            "body"     : text
        ]
        // future refactor: consider immediate persistence (w/o waiting for the server to return) to improve UX
        SocketIOManager.sharedInstance.sendEncryptedChat(newMessage)

        //let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        //self.messages += [message]
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
}

