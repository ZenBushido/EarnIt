//
//  VCAddDeleteGoal.swift
//  earnit
//
//  Created by Gaurav on 26/02/18.
//  Copyright © 2018 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class VCAddDeleteGoal : UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, DelegateUpdateGoal {
    
    var earnItChildUser  = EarnItChildUser()
    var IS_ADD = true
    var currentKeyboardOffset : CGFloat = 0.0
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var goalName: UITextField!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var goalAmount: UITextField!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var saveButton1: UIButton!
    
    var actionView = UIView()
    var earnItChildUsers = [EarnItChildUser]()
    var messageView = MessageView()
    var constX:NSLayoutConstraint?
    var constY:NSLayoutConstraint?
    
    var activeField:UITextField?
    @IBOutlet var tvGoals: UITableView!
    var idForDeleteGoal = Int()
    var earnItChildGoalList = [EarnItChildGoal]()
    var delegate: VCAddDeleteGoal?
    //MARK: View Cycle
    
    
    override func viewDidLoad() {
        self.earnItChildGoalList = self.earnItChildGoalList.reversed()
        self.tvGoals.allowsSelection = true
        self.tvGoals.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tvGoals.tableFooterView = UIView()
        self.tvGoals.reloadData()
        
        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
//        self.actionView.addGestureRecognizer(tapGesture)
        
        self.messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?[0] as? MessageView)!
        self.messageView.center = CGPoint(x: self.view.center.x,y :self.view.center.y-80)
        self.messageView.messageText.delegate = self
        
        let userAvatarUrlString = self.earnItChildUser.childUserImageUrl
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchParentUserDetailFromBackground), userInfo: nil, repeats: true)
        
        self.userImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX + self.earnItChildUser.childUserImageUrl!)
        
        /*if(!IS_ADD){
            print("trying to EDIT a goal")
            //lblTitle.text="Edit Goal"
            saveButton1.setTitle("Update", for: UIControlState.normal)
            goalName.text = self.earnItChildUser.earnItGoal.name
            goalAmount.text = String(self.earnItChildUser.earnItGoal.ammount!)
        }*/
        self.lblTitle.text = "\(EarnItAccount.currentUser.firstName!)'s Goals"
        saveButton1.setTitle("Save", for: UIControlState.normal)
        self.view.isUserInteractionEnabled = true

        self.goalName.delegate = self
        self.requestObserver()
        
        self.creatLeftPadding(textField: goalName)
        self.creatLeftPadding(textField: goalAmount)
        self.headerView.layer.addBorder(edge: .bottom, color: .white, thickness: 1.0)
        self.messageView.messageToLabel.text = "Message to  \(self.earnItChildUser.firstName!):"
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
    
    //MARK: Action Methods
    @IBAction func goBack(_ sender: Any) {
        self.view.endEditing(true)
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
       
        if self.goalName.text?.characters.count == 0 || self.goalAmount.text?.characters.count == 0{
            self.view.makeToast("Please complete goal name and goal amount")
//            let alert = showAlert(title: "", message: "Please complete goal name and goal amount")
//            self.present(alert, animated: true, completion: nil)
//            
        }else {
            let createdDate = Date().millisecondsSince1970
            self.IS_ADD = true
            if(self.IS_ADD) {
                self.showLoadingView()
                print("Should add" )
                addGoalForChild(childId: self.earnItChildUser.childUserId, amount: Int(self.goalAmount.text!)! ,createdDate : createdDate,goalName:self.goalName.text!, success: {_ in
                    
                    self.hideLoadingView()
                    self.view.makeToast("Goal added for \(self.earnItChildUser.firstName!)")
                    self.view.endEditing(true)
                    self.getGoalForCurrentUser()
                    //self.dismissScreen()
                    //                let alert = showAlertWithOption(title: "", message: "Goal added for \(self.earnItChildUser.firstName!)")
                    //                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreen))
                    //                self.present(alert, animated: true, completion: nil)
                }) { (error) -> () in
                    self.hideLoadingView()
                    self.view.makeToast("Add goal failed")
                }
            }
            else
            {  print("Should edit" )
                self.showLoadingView()
                editGoalForChild(id: self.earnItChildUser.earnItGoal.id!, childId: self.earnItChildUser.childUserId, amount: Int(self.goalAmount.text!)! ,createdDate : createdDate,goalName:self.goalName.text!, success: {_ in
                    
                    self.hideLoadingView()
                    self.view.makeToast("Goal updated for \(self.earnItChildUser.firstName!)")
                    self.view.endEditing(true)
                    self.dismissScreen()
                    //                let alert = showAlertWithOption(title: "", message: "Goal updated for \(self.earnItChildUser.firstName!)")
                    //                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreen))
                    //                self.present(alert, animated: true, completion: nil)
                }) { (error) -> () in
                    
                    self.hideLoadingView()
                    self.view.makeToast("Update goal failed")
                    //                let alert = showAlert(title: "Error", message: "Failed")
                    //                self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getGoalForCurrentUser(){
        self.goalName.text = ""
        self.goalAmount.text = ""
        getGoalsForChild(childId : earnItChildUser.childUserId, success: {
            (earnItGoalList) ->() in
            for earnItGoal in  earnItGoalList {
                EarnItChildUser.currentUser.earnItGoal = earnItGoal
            }
            self.earnItChildGoalList = earnItGoalList.reversed()
            self.tvGoals.reloadData()
        })
        { (error) -> () in
            self.view.makeToast("Error to get Goal list!")
        }
    }
    
    @IBAction func viewGotTapped(_ sender: Any) {
        print("viewGotTapped")
        self.view.endEditing(true)
    }
    
    
    //MARK: Text Field Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
       if textField == self.goalName{
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 20
        }
        return true
    }
    
    //MARK: Void Methods
    func dismissScreen(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchParentUserDetailFromBackground(){
        
        DispatchQueue.global().async {
            
            let keychain = KeychainSwift()
            guard  let _ = keychain.get("email") else  {
                print(" /n Unable to fetch user credentials from keychain \n")
                return
            }
            let email : String = (keychain.get("email")!)
            let password : String = (keychain.get("password")!)
            
            checkUserAuthentication(email: email, password: password, success: {
                
                (responseJSON) ->() in
                
                if (responseJSON["userType"].stringValue == "CHILD"){
                    
                    EarnItChildUser.currentUser.setAttribute(json: responseJSON)
                    //success(true)
                    
                }else {
                    
                    let keychain = KeychainSwift()
                    if responseJSON["token"].stringValue != keychain.get("token") || responseJSON["token"] == nil{
                        
                    }
                    EarnItAccount.currentUser.setAttribute(json: responseJSON)
                    keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
                    // success(true)
                }
                
            }) { (error) -> () in
                self.dismissScreenToLogin()
            }
            DispatchQueue.main.async {
                print("done calling background fetch for Parent....")
            }
        }
    }
    
    func dismissScreenToLogin(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
        self.present(loginController, animated: true, completion: nil)
    }
    /**
     Add observer to the View
     
     :param: nil
     */
    
    func requestObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide  , object: nil)
    }
    
    /**
     Responds to keyboard showing and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
//    func keyboardWillShow(_ notification:NSNotification){
//        
//        
//        let info = notification.userInfo!
//        let keyboardHeight: CGFloat = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
//        let keyboardYValue = self.view.frame.height - keyboardHeight
//        
//        if UIDevice().userInterfaceIdiom == .phone {
//            
//            switch UIScreen.main.nativeBounds.height {
//                
//            case 2208:
//                
//                if goalName.isFirstResponder || goalAmount.isFirstResponder{
//                    
//                    let saveButtonYValue = self.saveButton1.frame.size.height + self.saveButton1.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (saveButtonYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - saveButtonYValue + 100
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
//                }
//
//            default:
//                
//                if goalName.isFirstResponder || goalAmount.isFirstResponder {
//                    
//                    let saveButtonYValue = self.saveButton1.frame.size.height + self.saveButton1.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (saveButtonYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - saveButtonYValue + 100
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
//                }
//                
//            }
//            
//        }
//    }
    
    
    
    
    
    
    /**
     Responds to keyboard hiding and adjusts the View.
     
     :param: notification
     Type - NSNotification
     */
    
//    func keyboardWillHide(_ notification:NSNotification){
//        
//        
//        let keyboardOffset : CGFloat = rePostionView(currentOffset: self.currentKeyboardOffset)
//        self.view.frame.origin.y = keyboardOffset
//        self.currentKeyboardOffset = keyboardOffset
//        
//    }

    
    func keyboardWillShow(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        if let activeField = self.activeField {
            if activeField == goalAmount {
                let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
                let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height+210, 0.0)
                
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                var aRect : CGRect = self.view.frame
                aRect.size.height -= keyboardSize!.height
                
                if (!aRect.contains(activeField.frame.origin)){
                    
                    self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
                }
            }
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        // self.scrollView.isScrollEnabled = false
    }

    @IBAction func userImageGotTapped(_ sender: UITapGestureRecognizer) {
        
        let optionView  = (Bundle.main.loadNibNamed("OptionView", owner: self, options: nil)?[0] as? OptionView)!
        optionView.center = self.view.center
        optionView.userImageView.image = self.userImageView.image
        optionView.frame.origin.y = self.userImageView.frame.origin.y
        optionView.frame.origin.x = self.view.frame.origin.x + 160
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 480:
                optionView.frame.origin.x = self.view.frame.origin.x + 160
            case 960:
                optionView.frame.origin.x = self.view.frame.origin.x + 160
            case 1136:
                optionView.frame.origin.x = self.view.frame.origin.x + 100
            case 1334:
                optionView.frame.origin.x = self.view.frame.origin.x + 160
            case 2208:
                optionView.frame.origin.x = self.view.frame.origin.x + 200
            default:
                print("unknown")
            }
            
        }
        else if  UIDevice().userInterfaceIdiom == .pad {
            
            optionView.frame.origin.x = self.view.frame.origin.x + 200
        }
        //        optionView.addTaskButton.setImage(EarnItImage.setEarnItAddIcon(), for: .normal)
        //        optionView.showAllTaskButton.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
        //        optionView.approveTaskButton.setImage(EarnItImage.setEarnItAppShowTaskIcon(), for: .normal)
        //        optionView.showBalanceButton.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
        //        optionView.showGoalButton.setImage(EarnItImage.setEarnItGoalIcon(), for: .normal)
        //        optionView.messageButton.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
        
        optionView.firstOption.setImage(EarnItImage.setEarnItAddIcon(), for: .normal)
        optionView.secondOption.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
        optionView.thirdOption.setImage(EarnItImage.setEarnItAppShowTaskIcon(), for: .normal)
        optionView.forthOption.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
        optionView.fifthOption.setImage(EarnItImage.setEarnItGoalIcon(), for: .normal)
        optionView.sixthOption.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
        
        optionView.firstOption.setTitle("Add Task", for: .normal)
        optionView.secondOption.setTitle("All Task", for: .normal)
        optionView.thirdOption.setTitle("Approve Task", for: .normal)
        optionView.forthOption.setTitle("Balances", for: .normal)
        optionView.fifthOption.setTitle("Goals", for: .normal)
        optionView.sixthOption.setTitle("Message", for: .normal)
        
        
        self.actionView.addSubview(optionView)
        self.actionView.backgroundColor = UIColor.clear
        self.view.addSubview(self.actionView)
        optionView.doActionForSecondOption = {
            self.removeActionView()
            
            if self.earnItChildUser.earnItTasks.count > 0{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let parentDashBoardCheckin = storyBoard.instantiateViewController(withIdentifier: "parentDashBoard") as! ParentDashBoard
                parentDashBoardCheckin.prepareData(earnItChildUserForParent: self.earnItChildUser, earnItChildUsers: self.earnItChildUsers)
                let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                
                let slideMenuController  = SlideMenuViewController(mainViewController: parentDashBoardCheckin, leftMenuViewController: optionViewControllerPD)
                
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                slideMenuController.delegate = parentDashBoardCheckin
                self.present(slideMenuController, animated:false, completion:nil)
                
                
            }else {
                
                
                self.view.makeToast("No task available")
            }
   
        }
        
        optionView.doActionForFirstOption = {
        
            self.removeActionView()

            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let taskViewController = storyBoard.instantiateViewController(withIdentifier: "TaskView") as! TaskViewController
            taskViewController.earnItChildUserId = self.earnItChildUser.childUserId
            taskViewController.earnItChildUsers = self.earnItChildUsers
            self.present(taskViewController, animated:false, completion:nil)
            
        }
        
        optionView.doActionForFifthOption = {
            self.removeActionView()
        }
        
        optionView.doActionForFourthOption = {
            
            self.removeActionView()
            self.goToBalanceScreen()
        }
        
        optionView.doActionForThirdOption = {
            
            self.removeActionView()
            
            var hasPendingTask = false
            
            for pendingTask in self.earnItChildUser.earnItTasks {
                
                if pendingTask.status == TaskStatus.completed{
                    
                    hasPendingTask = true
                    break
                    
                }else {
                    
                    continue
                }
            }
            
            if hasPendingTask == false {
                
                self.view.makeToast("There are no tasks for approval")
                //            let alert = showAlert(title: "", message: "There are no tasks for approval")
                //            self.present(alert, animated: true, completion: nil)
                
            }else {
    
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let pendingTasksScreen = storyBoard.instantiateViewController(withIdentifier: "PendingTasksScreen") as! PendingTasksScreen
                pendingTasksScreen.prepareData(earnItChildUserForParent: self.earnItChildUser, earnItChildUsers: self.earnItChildUsers)
                let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                let slideMenuController  = SlideMenuViewController(mainViewController: pendingTasksScreen, leftMenuViewController: optionViewControllerPD)
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                //slideMenuController.delegate = pendingTasksScreen
                self.present(slideMenuController, animated:false, completion:nil)
            }
        }
        
        optionView.doActionForSixthOption = {
            
            self.removeActionView()
            
            let messageContainerView = UIView()
            messageContainerView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
            messageContainerView.backgroundColor = UIColor.clear
            self.messageView.messageText.text = ""
            messageContainerView.addSubview(self.messageView)
            self.view.addSubview(messageContainerView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.messageContainerDidTap(_:)))
            tap.delegate = self
            messageContainerView.addGestureRecognizer(tap)
            
            self.messageView.dissmissMe = {
                self.messageView.removeFromSuperview()
                messageContainerView.removeFromSuperview()
                //self.enableBackgroundView()
            }
            
            self.messageView.callControllerForSendMessage = {
                
                self.showLoadingView()
                self.messageView.activityIndicator.startAnimating()
                if self.messageView.messageText.text.characters.count == 0 || self.messageView.messageText.text.isEmptyField == true{
                    
                    self.view.endEditing(true)
                    self.view.makeToast("Please enter a message")
                    self.hideLoadingView()
                    self.messageView.activityIndicator.stopAnimating()
                    //                let alert = showAlert(title: "", message: "Please enter a message")
                    //                self.present(alert, animated: true, completion: nil)
                    
                }else {
                    
                    callUpdateApiForChild(firstName: self.earnItChildUser.firstName,childEmail: self.earnItChildUser.email,childPassword: self.earnItChildUser.password,childAvatar: self.earnItChildUser.childUserImageUrl!,createDate: self.earnItChildUser.createDate,childUserId: self.earnItChildUser.childUserId, childuserAccountId: self.earnItChildUser.childAccountId,phoneNumber: self.earnItChildUser.phoneNumber,fcmKey : self.earnItChildUser.fcmToken, message: self.messageView.messageText.text, success: {
                        
                        (childUdateInfo) ->() in
                        
                        createEarnItAppChildUser( success: {
                            
                            (earnItChildUsers) -> () in
                            
                            EarnItAccount.currentUser.earnItChildUsers = earnItChildUsers
                            self.hideLoadingView()
                            self.messageView.activityIndicator.stopAnimating()
                            self.messageView.removeFromSuperview()
                            messageContainerView.removeFromSuperview()
                            
                        }) {  (error) -> () in
                            
                            print("error")
                        }
                        
                    }) { (error) -> () in
                        self.hideLoadingView()
                        self.messageView.activityIndicator.stopAnimating()
                        self.view.makeToast("Send Message Failed")
                        
                        
                        //                let alert = showAlert(title: "Error", message: "Update Child Failed")
                        //                self.present(alert, animated: true, completion: nil)
                        print(" Set status completed failed")
                    }
                }
            }
            
            var dView:[String:UIView] = [:]
            dView["MessageView"] = self.messageView
            
            let h_Pin = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(36)-[MessageView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: dView)
            self.view.addConstraints(h_Pin)
            
            let v_Pin = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(36)-[MessageView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dView)
            self.view.addConstraints(v_Pin)
            
            self.constY = NSLayoutConstraint(item: self.messageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constY!)
            
            
            self.constX = NSLayoutConstraint(item: self.messageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constX!)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.50, options: UIViewAnimationOptions.layoutSubviews, animations: { () -> Void in
                self.messageView.alpha = 1
                
                self.view.layoutIfNeeded()
            }) { (value:Bool) -> Void in
                
            }
        }
    }
    
    //MARK: Void Methods
    
    func actionViewDidTapped(_ sender: UITapGestureRecognizer){
        print("actionViewDidTapped..")
        self.removeActionView()
    }
    
    func removeActionView(){
        for view in self.actionView.subviews {
            view.removeFromSuperview()
        }
        self.actionView.removeFromSuperview()
    }
    
    func messageContainerDidTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
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
    
    func goToBalanceScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let balanceScreen = storyBoard.instantiateViewController(withIdentifier: "BalanceScreen") as! BalanceScreeen
        balanceScreen.earnItChildUsers = self.earnItChildUsers
        balanceScreen.earnItChildUser = self.earnItChildUser
        if self.earnItChildUser.earnItGoal.cash! + self.earnItChildUser.earnItGoal.tally! + self.earnItChildUser.earnItGoal.ammount! == 0{
            self.view.makeToast("No balance to display!!")
        }else {
            self.present(balanceScreen, animated:true, completion:nil)
        }
    }
    
    //MARK: TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGesture)
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.removeGestureRecognizer(tapGesture)
        activeField = nil
    }
    
    //MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.earnItChildGoalList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let childCell = self.tvGoals.dequeueReusableCell(withIdentifier: "ChildCell", for: indexPath as IndexPath) as! ChildCell
        let objGoal = earnItChildGoalList[indexPath.row]
        childCell.childName.text = "\(objGoal.name!):  $\(objGoal.ammount!)"
        childCell.childName.isUserInteractionEnabled = false
        childCell.btnDeleteChildRow.tag = objGoal.id!
        childCell.btnDeleteChildRow.setTitleColor(UIColor.clear, for: UIControlState.normal)
        childCell.btnDeleteChildRow.titleLabel?.text = "\(objGoal.name!)"
        childCell.btnDeleteChildRow.addTarget(self, action: #selector(deleteGoalRowButtonAction), for: UIControlEvents.touchUpInside)
        childCell.btnCellRowBG.tag = indexPath.row
        childCell.btnCellRowBG.addTarget(self, action: #selector(cellRowTapButtonAction), for: UIControlEvents.touchUpInside)
        
        return childCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("yes selected....")
    }
    
    func cellRowTapButtonAction(_ sender: Any) {
        if (activeField == nil) {
            let btnDelete:UIButton = sender as! UIButton
            let objGoal = earnItChildGoalList[btnDelete.tag]
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let updateGoalVC = storyBoard.instantiateViewController(withIdentifier: "VCUpdateGoal") as! VCUpdateGoal
            updateGoalVC.IS_ADD = false
            updateGoalVC.earnItChildUser = self.earnItChildUser
            updateGoalVC.earnItChildUsers = self.earnItChildUsers
            updateGoalVC.objEarnItGoal = objGoal
            updateGoalVC.delegate = self
            self.present(updateGoalVC, animated:true, completion:nil)
        }
        else {
            self.view.endEditing(true)
        }
    }
    
    //MARK: Delete Goal
    
    func deleteGoalRowButtonAction(_ sender: Any) {
        print("print goal")
        let btnDelete:UIButton = sender as! UIButton
        self.idForDeleteGoal = btnDelete.tag
        let alert = showAlertWithOption(title: "Are you sure you want to delete \(btnDelete.titleLabel!.text!) from your account? Goal will be deleted.", message: "")
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: self.deleteGoalAction))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteGoalAction(_ sender: Any) {
        
        print("calling delete Goal....")
        self.showLoadingView()
        callForDeleteGoal(goal_id: self.idForDeleteGoal, success: {
            
            (errorcode) ->() in
            print(errorcode)
            if (errorcode == "9003"){
                self.hideLoadingView()
                self.view.makeToast("Error to delete goal. Please try later!")
                //self.fetchParentUserDetailFromBackground()
            }else {
                
                createEarnItAppChildUser( success: {
                    (earnItChildUsers) -> () in
                    EarnItAccount.currentUser.earnItChildUsers = earnItChildUsers
                    self.earnItChildUsers = EarnItAccount.currentUser.earnItChildUsers
                    self.getGoalForCurrentUser()
                    self.hideLoadingView()
                    
                }) {  (error) -> () in
                    print("error")
                }
            }
        }) { (error) -> () in
            self.hideLoadingView()
            self.view.makeToast("Failed to Delete!")
            //            let alert = showAlert(title: "Error", message: "Add Child Failed")
            //            self.present(alert, animated: true, completion: nil)
            //            print(" Set status completed failed")
        }
    }

}
