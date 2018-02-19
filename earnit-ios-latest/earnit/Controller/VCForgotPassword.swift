//
//  VCForgotPassword.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/3/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class VCForgotPassword : UIViewController {
    
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var lblText: UILabel!

    var currentKeyboardOffset : CGFloat = 0.0
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var isEmailValid = Bool()
    
    override func viewDidLoad() {
        self.requestObserver()
        self.creatLeftPadding(textField: tfEmail)
        self.lblText.text = "Enter your email address to receive your account password."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tfEmail.text = ""
//        self.tfEmail.text = "g@gmail.com"
    }
    
    //MARK: Void Methods
    
    func isValidEmail() {
        if (tfEmail.text?.isEmail)! {
            self.isEmailValid = true
        }
        else {
            self.isEmailValid = false
        }
    }
    
    //MARK: Action Methods
    
    @IBAction func emailDidEndEditing(_ sender: Any) {
        if (tfEmail.text?.isEmail)! {
            self.isEmailValid = true
        }
        else {
            self.isEmailValid = false
        }
    }

    @IBAction func passwordDidEndEditing(_ sender: UITextField) {
        
    }
    
    @IBAction func goBackToLogin(_ sender: Any) {
        print("go back to Login")
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        print("go back to Login")
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CheckValidityAndCallSignUpApi(_ sender: Any) {
        self.view.endEditing(true)
        self.isValidEmail()
        print("Inside CheckValidityAndCallSignUpApi")
        self.showLoadingView()
        if (self.tfEmail.text?.count)! == 0  {
            self.hideLoadingView()
            self.view.makeToast("Please enter the account email.")
        }else if self.isEmailValid == false{
            self.hideLoadingView()
            self.view.makeToast("Invalid Email")
        }
        else {
            callForgotPasswordApiForUser(email: self.tfEmail.text!, success: {
                (responseJSON) ->() in
                self.hideLoadingView()
                if (responseJSON["message"][0].stringValue == "Mail sent."){
                    let alert = UIAlertController(title: "", message: "Your password has been sent. Please check your email\n\(self.tfEmail.text!)\nand return to Earnit login.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: self.goBackToLoginSignup))
                    self.present(alert, animated: true, completion: nil)
                }
                else if (responseJSON["code"][0] == 9001) {
                    //let alert = showAlertWithOption(title: "This email is not associated and an EarnIt! account, please try again.", message: "")
                    let alert = showAlertWithOption(title: "Sorry, we don't have that username or account in our system.Please verify the information or contact support at\nsupport@myearnitapp.com", message: "")
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: self.goBackToLoginSignup))
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = showAlertWithOption(title: "This email is not associated and an EarnIt! account, Failed to send password, please try again!", message: "")
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: self.goBackToLoginSignup))
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (error) -> () in
                self.view.makeToast("Failed to send password, please try again!")
                self.tfEmail.text = ""
            }
        }
    }
    
    //MARK: go to login/signup
    func goBackToLoginSignup(_ sender: Any) {
        print("go back to Login")
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    //ovrride
    func dismissScreen(alert: UIAlertAction) {
       self.dismiss(animated: true, completion: nil)
    }
    /**
     Add observer to the View
     
     :param: nil
     */
    
    func requestObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide  , object: nil)
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
     Responds to keyboard showing and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
    func keyboardWillShow(_ notification:NSNotification){
        //scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
    }
    
    /**
     Responds to keyboard hiding and adjusts the View.
     
     :param: notification
     Type - NSNotification
     */
    
    func keyboardWillHide(_ notification:NSNotification){
        print("Keyboard will hide...")
//        let keyboardOffset : CGFloat = rePostionView(currentOffset: self.currentKeyboardOffset)
//        self.view.frame.origin.y = keyboardOffset
//        self.currentKeyboardOffset = keyboardOffset
         //scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func showLoadingView(){
//        self.scrollView.alpha = 0.7
//        self.scrollView.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
    
    func hideLoadingView(){
//        self.scrollView.alpha = 1
//        self.scrollView.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func viewGotTapped(_ sender: Any) {
        print("View got tapped")
        self.view.endEditing(true)
    }
}
        

