//
//  ViewController.swift
//  friendFinder
//
//  

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate, CancelButtonDelegate{
//    var colorArray = ColorSchemeOf(ColorScheme.Analogous, FlatGreen(), true)
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let textField = userNameInput
        textField.delegate = self
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var userNameInput: UITextField!
    
    @IBAction func findFriendsSegueueButton(sender: AnyObject) {
        let userName: String = userNameInput.text!
        print(userName)
        performSegueWithIdentifier("findFriendsSegue", sender: userName)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "findFriendsSegue" {
            var userName = userNameInput.text!
            print(sender)
            
            if let whatSender = sender {
                print(whatSender, " THIS IS THE SENDER")
            }
//            userName = sender as! String
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! MapViewController

            controller.userName = userName
            
//            signInViewController(controller: MapViewController, didFinishAddingUser: userName)
//            print(isEditing!)
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        print("WTF")
        return false
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        print("we dismissed the view controller")
    }
    


}


