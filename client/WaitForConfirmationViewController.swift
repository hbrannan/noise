import UIKit

class WaitForConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackButton()
        /*
         TODO: while on "wait screen" be able to segue to chatScreen for that particular friend if key exchange completed
         
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleCompletedKeyExchange),
            name: "completedKeyExchange",
            object: nil)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        self.performSegueWithIdentifier("chatScreenSegue", sender: self)
    }
    
    func setUpBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    func backButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
        
    }

}

