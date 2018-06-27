
//  LoginPageController.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/19/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class LoginPageController : UIViewController , UITextFieldDelegate , UIGestureRecognizerDelegate{
    
    @IBOutlet var earnItLogo: UIImageView!
    @IBOutlet var earnItTagLine: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    //keyboardOffset
    var currentKeyboardOffset : CGFloat = 0.0
    
    @IBOutlet var donotHaveAnAccountLabel: UILabel!
    @IBOutlet var signUpRestrictionMessageForChild: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var lblRememberMe: UILabel!
    @IBOutlet var btnRememberMe: UIButton!
    @IBOutlet var btnForgotPswrd: UIButton!
    
    var popUpView = UILabel()
    
    var isEmailValid = Bool()
    var isRememberMeChecked = Bool()

    //override View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestObserver()
        self.creatLeftPadding(textField: emailTextField)
        self.creatLeftPadding(textField: passwordTextField)
        signUpButton.titleLabel?.numberOfLines = 1
        signUpButton.titleLabel?.adjustsFontSizeToFitWidth = true
        signUpButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        let keychain = KeychainSwift()
        if (keychain.get("email") != nil && keychain.get("password") != nil) {
            self.btnRememberMe.setImage(UIImage.init(named: "remember_me_checkbox.png"), for: UIControlState.normal)
            self.isRememberMeChecked = true
        }
        else {
            self.btnRememberMe.setImage(UIImage.init(named: "remember_me_box.png"), for: UIControlState.normal)
            self.isRememberMeChecked = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        print("Called view did appear")
        self.emailTextField.text=""
        self.passwordTextField.text=""
        self.emailTextField.inputAccessoryView = nil
        self.passwordTextField.inputAccessoryView = nil
        signUpRestrictionMessageForChild.alpha = 0
        //self.donotHaveAnAccountLabel.alpha = 1
        self.signUpButton.alpha = 1
        
        //self.getAppsUsedMemory()
//        self.emailTextField.text = "tracy@tracy.com"//"cheryl@cheryl.com"//"ssgappz@gmail.com"////"Tracyliv@gmail.com"//"zzz@zzz.com"//"ccv@ccv@gmail.com"//"fessn14@gmail.com"//"dadch4@gmail.com"//"mah@gmail.com "//"bbb@bbb.com"
//        self.passwordTextField.text = "test123"//"dingo1987"//"qqq123" //"dingo1987" //"test123"//"123456"//"qqq123"//"test123"
    }

    //MARK: Get Apps Usage
    
    func getAppsUsedMemory() {
        
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let usedMegabytes = taskInfo.resident_size/1000000
            print("used megabytes: \(usedMegabytes)")
        } else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
    }
    
    @IBAction func emailDidEndEditing(_ sender: Any){
        if (self.emailTextField.text?.isEmail)! {
            self.isEmailValid = true
        }else {
            self.isEmailValid = false
        }
    }
    
    /**
    To assign Left Padding for Textfield
     
     :param: UITextField
     */
    
    func creatLeftPadding(textField:UITextField) {
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.size.height))
        textField.leftView = leftPadding
        textField.leftViewMode = UITextFieldViewMode.always
    }
    
    /**
     Add observer to the View
     
     :param: nil
     */
    
    func requestObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(LoginPageController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginPageController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide  , object: nil)
    }

    /**
     Responds to keyboard showing and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
   // [scroll setContentOffset:CGPointMake(0, (textField.superview.frame.origin.y + (textField.frame.origin.y))) animated:YES];
    
    func keyboardWillShow(_ notification:NSNotification){
        scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
    }
    
//    func keyboardWillShow(_ notification:NSNotification){
//        
//        
//        let info = notification.userInfo!
//        let keyboardHeight: CGFloat = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
//        let keyboardYValue = self.view.frame.height - keyboardHeight
//        
//        if UIDevice().userInterfaceIdiom == .pad {
//            
//            switch UIScreen.main.nativeBounds.height {
//                
//            case 2732:
//                if emailTextField.isFirstResponder {
//                    
//                    let emailYValue = self.emailTextField.frame.size.height + self.emailTextField.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (emailYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - emailYValue + 470
//                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            }, completion: { (completed) -> Void in
//                                
//                                
//                            })
//                            
//                        }
//                        
//                    }
//                    
//                }else if passwordTextField.isFirstResponder{
//                    
//                    let passwordYValue = self.passwordTextField.frame.size.height + self.passwordTextField.frame.origin.y
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if passwordYValue > (keyboardYValue + 10.0) {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - passwordYValue + 470
//                            UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            })
//                        }
//                    }
//                    
//                }
//                
//            default:
//                
//                if emailTextField.isFirstResponder {
//                    
//                    let emailYValue = self.emailTextField.frame.size.height + self.emailTextField.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (emailYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - emailYValue + 330
//                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            }, completion: { (completed) -> Void in
//                                
//                                
//                            })
//                            
//                        }
//                        
//                    }
//                    
//                }else if passwordTextField.isFirstResponder{
//                    
//                    let passwordYValue = self.passwordTextField.frame.size.height + self.passwordTextField.frame.origin.y
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if passwordYValue > (keyboardYValue + 10.0) {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - passwordYValue + 330
//                            UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            })
//                        }
//                    }
//                    
//                }
//            
//        }
//        
//        }else if UIDevice().userInterfaceIdiom == .phone {
//    
//        switch UIScreen.main.nativeBounds.height {
//        
//        case 2208:
//        
//        if emailTextField.isFirstResponder {
//            
//            let emailYValue = self.emailTextField.frame.size.height + self.emailTextField.frame.origin.y
//            
//            if self.currentKeyboardOffset == 0.0 {
//                
//                if (emailYValue ) > keyboardYValue + 10.0 {
//                    
//                    self.currentKeyboardOffset = (keyboardYValue + 50.0) - emailYValue + 230
//                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                        self.view.frame.origin.y -= self.currentKeyboardOffset
//                        
//                    }, completion: { (completed) -> Void in
//                        
//                        
//                    })
//                    
//                }
//                
//            }
//            
//        }else if passwordTextField.isFirstResponder{
//            
//            let passwordYValue = self.passwordTextField.frame.size.height + self.passwordTextField.frame.origin.y
//            if self.currentKeyboardOffset == 0.0 {
//                
//                if passwordYValue > (keyboardYValue + 10.0) {
//                    
//                    self.currentKeyboardOffset = (keyboardYValue + 50.0) - passwordYValue + 210
//                    UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                        self.view.frame.origin.y -= self.currentKeyboardOffset
//                        
//                    })
//                }
//            }
//            
//        }
//        
//        default:
//        
//        if emailTextField.isFirstResponder {
//            
//            let emailYValue = self.emailTextField.frame.size.height + self.emailTextField.frame.origin.y
//            
//            if self.currentKeyboardOffset == 0.0 {
//                
//                if (emailYValue ) > keyboardYValue + 10.0 {
//                    
//                    self.currentKeyboardOffset = (keyboardYValue + 50.0) - emailYValue + 213
//                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                        self.view.frame.origin.y -= self.currentKeyboardOffset
//                        
//                    }, completion: { (completed) -> Void in
//                        
//                        
//                    })
//                    
//                }
//                
//            }
//            
//        }else if passwordTextField.isFirstResponder{
//            
//            let passwordYValue = self.passwordTextField.frame.size.height + self.passwordTextField.frame.origin.y
//            if self.currentKeyboardOffset == 0.0 {
//                
//                if passwordYValue > (keyboardYValue + 10.0) {
//                    
//                    self.currentKeyboardOffset = (keyboardYValue + 50.0) - passwordYValue + 210
//                    UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                        self.view.frame.origin.y -= self.currentKeyboardOffset
//                        
//                    })
//                }
//            }
//            
//          }
//            
//        }
//        
//    }
//        
//}
    
    /**
     Responds to keyboard hiding and adjusts the View.
     
     :param: notification
     Type - NSNotification
     */
    
    func keyboardWillHide(_ notification:NSNotification){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        let keyboardOffset : CGFloat = rePostionView(currentOffset: self.currentKeyboardOffset)
//        self.view.frame.origin.y = keyboardOffset
//        self.currentKeyboardOffset = keyboardOffset
    }
 
    //MARK: Void Methods
    
    func showLoadingView(){
        self.view.alpha = 0.7
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
    
    func hideLoadingView(){
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    //MARK: Action Methods
    
    /*
 
    check authentication for user Inputs
    and redirect to Dashboard
 
    */
    @IBAction func remembermeButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        if (self.isRememberMeChecked == true) {
            self.btnRememberMe.setImage(UIImage.init(named: "remember_me_box.png"), for: UIControlState.normal)
            self.isRememberMeChecked = false
        }
        else {
            self.btnRememberMe.setImage(UIImage.init(named: "remember_me_checkbox.png"), for: UIControlState.normal)
            self.isRememberMeChecked = true
        }
    }
    
    @IBAction func signButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        print("email text \(String(describing: emailTextField.text))")
        print("password text \(String(describing: passwordTextField.text))")
        self.showLoadingView()
        if self.emailTextField.text?.characters.count == 0 || self.passwordTextField.text?.characters.count == 0{
            
            self.hideLoadingView()
            self.view.makeToast("Please complete all the fields")
//            let alert = showAlert(title: "", message: "Please complete all the fields")
//            self.present(alert, animated: true, completion: nil)
        }else {
        checkUserAuthentication(email: self.emailTextField.text!, password: self.passwordTextField.text!, success: {
            (responseJSON) ->() in
            print("Reponse json after login - \(responseJSON)")
            if (responseJSON["email"].string == nil || responseJSON["email"].stringValue == "") {
                self.hideLoadingView()
                self.view.makeToast("Login Failed")
                //            let alert = showAlert(title: "Error", message: "Login Failed")
                //            self.present(alert, animated: true, completion: nil)
                //            print("failed")
                self.passwordTextField.text = ""
                return
            }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let keychain = KeychainSwift()
            
            print(responseJSON["email"])
            print(responseJSON["email"].stringValue)
            print(responseJSON["password"].stringValue)
            
            keychain.set(responseJSON["email"].stringValue, forKey: "email")
            //keychain.set(responseJSON["password"].stringValue, forKey: "password")
            keychain.set(self.passwordTextField.text!, forKey: "password")
            keychain.set(true, forKey: "isActiveUser")
            keychain.set(true, forKey: "isProfileUpdated")

            let fcmToken : String? = keychain.get("token")
            
            if (responseJSON["userType"].stringValue == "CHILD"){
                EarnItChildUser.currentUser.setAttribute(json: responseJSON)
                if responseJSON["fcmToken"].stringValue != keychain.get("token") ||  responseJSON["fcmToken"].stringValue == nil  || responseJSON["fcmToken"].stringValue == ""{
                    /*print("fcm token is null")
                    print("firstname \(EarnItChildUser.currentUser.firstName)")
                    print("lastName \(EarnItChildUser.currentUser.lastName)")
                    print(EarnItChildUser.currentUser.email)
                    print(EarnItChildUser.currentUser.password)
                    print(EarnItChildUser.currentUser.childUserImageUrl!)
                    print(EarnItChildUser.currentUser.createDate)
                    print("child id \(EarnItChildUser.currentUser.childUserId)")
                    print(EarnItChildUser.currentUser.phoneNumber)*/

                    callUpdateApiForChild(firstName: EarnItChildUser.currentUser.firstName,childEmail: EarnItChildUser.currentUser.email,childPassword: EarnItChildUser.currentUser.password,childAvatar: EarnItChildUser.currentUser.childUserImageUrl!,createDate: EarnItChildUser.currentUser.createDate,childUserId: EarnItChildUser.currentUser.childUserId, childuserAccountId: EarnItChildUser.currentUser.childAccountId,phoneNumber: EarnItChildUser.currentUser.phoneNumber,fcmKey : fcmToken, message: EarnItChildUser.currentUser.childMessage, success: {
                        
                        (childUdateInfo) ->() in
                        
                        EarnItChildUser.currentUser.fcmToken = fcmToken
                        UIApplication.shared.registerForRemoteNotifications()
                        
                    }) { (error) -> () in
                        self.hideLoadingView()
                        let alert = showAlert(title: "Error", message: "Update Child Failed")
                        self.present(alert, animated: true, completion: nil)
                        print(" Set status completed failed")
                    }
                }
               
        if EarnItChildUser.currentUser.childMessage == nil || EarnItChildUser.currentUser.childMessage == "" {
            
            let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
            self.present(childDashBoard, animated: false, completion: nil)
        }else {
            let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "MessageDisplayScreen") as! MessageDisplayScreen
            self.present(childDashBoard, animated: false, completion: nil)
                }
            }else {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.ReferenceType.local
                formatter.dateFormat = "h:mm a"
                formatter.amSymbol = "AM"
                formatter.pmSymbol = "PM"
                
                print("START earnIt parent creation \(responseJSON["firstName"].stringValue)")
                print(Date().millisecondsSince1970)
                EarnItAccount.currentUser.setAttribute(json: responseJSON)
                print("END earnIt parent creation \(responseJSON["firstName"].stringValue)")
//                print(Date().millisecondsSince1970)
                if responseJSON["fcmToken"].stringValue != keychain.get("token") || responseJSON["fcmToken"].stringValue == nil || responseJSON["fcmToken"].stringValue == ""{
           
                    print("fcm token is null")
                    callUpdateProfileApiForParentt(firstName: EarnItAccount.currentUser.firstName, lastName: EarnItAccount.currentUser.lastName, phoneNumber: EarnItAccount.currentUser.phoneNumber!, updatedPassword: EarnItAccount.currentUser.password,imageUrl: EarnItAccount.currentUser.avatar!,fcmKey : fcmToken,success: {
                        
                        (earnItParentInfo) ->() in
                        
                        EarnItAccount.currentUser.fcmToken = fcmToken
                        UIApplication.shared.registerForRemoteNotifications()
                        
                    }) { (error) -> () in
                        
                        let alert = showAlert(title: "Error", message: "Update Profile Failed")
                        self.present(alert, animated: true, completion: nil)
                        print(" Set status completed failed")
                    }
                }
                
                /*if (EarnItAccount.currentUser.earnItChildUsers.count == 0) {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "VCHomeAddChild") as! VCHomeAddChild
                    let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                    let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                    //            slideMenuController.delegate = parentLandingPage
                    self.present(slideMenuController, animated:false, completion:nil)
                    
                    //                self.present(parentLandingPage, animated:false, completion:nil)
                    
                    //                self.navigationController?.pushViewController(parentLandingPage, animated: false)
                }
                else {
                    
                    let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
                    
                    let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                    
                    let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
                    
                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                    slideMenuController.delegate = parentLandingPage
                    
                    self.present(slideMenuController, animated:false, completion:nil)
                }*/
                
                let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
                
                let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                
                let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
                
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                slideMenuController.delegate = parentLandingPage
                
                self.present(slideMenuController, animated:false, completion:nil)
            }
            
        }) { (error) -> () in
            
            self.hideLoadingView()
            self.view.makeToast("Login Failed")
//            let alert = showAlert(title: "Error", message: "Login Failed")
//            self.present(alert, animated: true, completion: nil)
//            print("failed")
            self.passwordTextField.text = ""
         }            
       }
    }
   
    @IBAction func viewGotTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
   
    @IBAction func signUpButtonClicked(_ sender: Any) {
        let alert = showAlertWithOption(title: "Are you a parent user?", message: "")
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.goToSignUpPage))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: self.showRestrictionMessageForSignUp))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let forgotpasswordPage = storyBoard.instantiateViewController(withIdentifier: "VCForgotPassword") as! VCForgotPassword
        self.present(forgotpasswordPage, animated: true, completion: nil)
    }
    
    //ovrride
    func goToSignUpPage(alert: UIAlertAction) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpViewPage = storyBoard.instantiateViewController(withIdentifier: "SignUpView") as! SignUpViewController
        self.present(signUpViewPage, animated: true, completion: nil)
    }
    
    func showRestrictionMessageForSignUp(alert: UIAlertAction){
        signUpRestrictionMessageForChild.alpha = 1
        //self.donotHaveAnAccountLabel.alpha = 0
        self.signUpButton.alpha = 0
        self.perform(#selector(self.hideRestrictionMessageForSignUp), with: self, afterDelay: 6)
    }
    
    
    func hideRestrictionMessageForSignUp(){
        signUpRestrictionMessageForChild.alpha = 0
        //self.donotHaveAnAccountLabel.alpha = 1
        self.signUpButton.alpha = 1
    }
    
}





