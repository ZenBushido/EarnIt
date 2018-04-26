//
//  VCAdjustBalance.swift
//  earnit
//
//  Created by Gaurav on 10/4/17.
//  Copyright © 2018 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class VCAdjustBalance : UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var GoalName: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var goalNameHeight: NSLayoutConstraint!
    @IBOutlet var lblTotalAccountBalance: UILabel!
    @IBOutlet var lblCurrentBalance: UILabel!
    @IBOutlet var lblAdjustmentAmount: UILabel!
    @IBOutlet var userImageView: UIImageView!
    var earnItChildUser =  EarnItChildUser()
    var earnItChildUsers = [EarnItChildUser]()
    var actionView = UIView()
    var messageView = MessageView()
    var constX:NSLayoutConstraint?
    var constY:NSLayoutConstraint?
    var isActiveUserChild = false

    var earnItChildGoalList = [EarnItChildGoal]()
    var objChildGoal = EarnItChildGoal()
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblBarTitle: UILabel!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var tvAdjustmentReason: UITextView!
    var activeTextView:UITextView?
    var activeField:UITextField?
    var indexObject: Int = 0
    var goalPicker = UIPickerView()
    let arrayPickerSelection = ["Add", "Subtract"]
    @IBOutlet var tfOperation:UITextField?
    @IBOutlet var tfAdjustBalance:UITextField?
    var cashAmount:Int = 0
    var goalsAmount:Int = 0

    //MARK: View Cycle
    
    override func viewDidLoad() {
        //self.lblTitle.text = "\(EarnItAccount.currentUser.firstName!)" + "'s " + "Balances"
        self.lblTitle.text = "Balance Adjustment"
        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGesture)
        
        self.messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?[0] as? MessageView)!
        self.messageView.center = CGPoint(x: self.view.center.x,y :self.view.center.y-80)
        self.messageView.messageText.delegate = self
        
        let userAvatarUrlString = self.earnItChildUser.childUserImageUrl
        self.userImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX + userAvatarUrlString!)
        self.setupUI()
        self.changeGoalValues(indexx: self.indexObject)
    }
    
    //MARK: Void Methods
    
    func setupUI() {
        self.messageView.messageToLabel.text = "Message to  \(self.earnItChildUser.firstName!):"
        self.GoalName.isHidden = true
        self.lblTotalAccountBalance.textColor = UIColor.clear
        self.tvAdjustmentReason.delegate = self
        self.tvAdjustmentReason.text = ""
        self.tfOperation?.attributedPlaceholder = NSAttributedString(string:"Select", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.tfOperation?.text = "Add"
        
        self.lblCurrentBalance.textAlignment = NSTextAlignment.center
        self.lblCurrentBalance.layer.borderWidth = 1.0
        self.lblCurrentBalance.layer.borderColor = UIColor.white.cgColor
        self.lblCurrentBalance.layer.cornerRadius = 4
        self.tvAdjustmentReason.layer.borderWidth = 1.0
        self.tvAdjustmentReason.layer.borderColor = UIColor.white.cgColor
        self.tvAdjustmentReason.layer.cornerRadius = 4
        self.lblAdjustmentAmount.textAlignment = NSTextAlignment.center
        self.lblAdjustmentAmount.layer.borderWidth = 1.0
        self.lblAdjustmentAmount.layer.borderColor = UIColor.white.cgColor
        self.lblAdjustmentAmount.layer.cornerRadius = 4
        self.lblTotalAccountBalance.textAlignment = NSTextAlignment.center
        self.lblTotalAccountBalance.layer.borderWidth = 1.0
        self.lblTotalAccountBalance.layer.borderColor = UIColor.white.cgColor
        self.lblTotalAccountBalance.layer.cornerRadius = 4
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
    
    func goToAppsMonitorScreen(){
        //Navigate to Monitoring
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let appsmonitorController = storyBoard.instantiateViewController(withIdentifier: "VCAppsMonitor") as! VCAppsMonitor
        appsmonitorController.earnItChildUsers = self.earnItChildUsers
        self.present(appsmonitorController, animated:true, completion:nil)
    }
    
    //MARK: Goal Balance Vlaues Change Methods
    
    func changeGoalValues(indexx : Int) {
        //let earnItGoal = self.earnItChildGoalList[indexx]
        self.objChildGoal = self.earnItChildGoalList[indexx]
        self.lblBarTitle.text = "\(self.objChildGoal.name!)"
        self.tfAdjustBalance?.text = ""
        self.tvAdjustmentReason?.text = ""
        self.cashAmount = 0
        self.goalsAmount = 0
        for earnItGoalObj in self.earnItChildGoalList {
            self.earnItChildUser.earnItGoal = earnItGoalObj
//            var amountValue:Int = 0
//            for objAdjustment in earnItGoalObj.arrAdjustments {
//                amountValue = (objAdjustment["amount"]! as? Int)! + amountValue
//            }
            self.cashAmount = earnItGoalObj.cash! + self.cashAmount
            self.goalsAmount = earnItGoalObj.tally! + self.goalsAmount
//            self.lblCurrentBalance.text = "\(earnItGoalObj.ammount! + amountValue)" //Int("\(self.objChildGoal.ammount!)")! + amountValue
            
        }
//        self.cashAmount = self.objChildGoal.cash! + self.cashAmount
//        self.goalsAmount = self.objChildGoal.tally! + self.goalsAmount
//        self.adjustBalanceValues_Calculation()
//        self.lblCurrentBalance.text = "\(self.objChildGoal.tally!)/\(self.cashAmount + self.goalsAmount)"
        var amountValue:Int = 0
        for objAdjustment in self.objChildGoal.arrAdjustments {
            amountValue = (objAdjustment["amount"]! as? Int)! + amountValue
        }
        self.lblCurrentBalance.text = "\(self.objChildGoal.ammount! + amountValue)"
    }
    
    func adjustBalanceValues_Calculation() {
        var amountValue:Int = 0
        for objAdjustment in self.objChildGoal.arrAdjustments {
            print(objAdjustment)
            //            print(objAdjustment["amount"])
            //            amountValue = objAdjustment["amount"] + amountValue
        }
        print(amountValue)
    }
    
    @IBAction func backwardForwardButton_Tap(_ sender: Any) {
        if ((sender as AnyObject).tag == 10) {
            //backward
            self.indexObject = self.indexObject-1
            if (self.indexObject < 0) {
                self.indexObject = 0
            }
        }
        else {
            //forward
            self.indexObject = self.indexObject+1
            if (self.indexObject >= self.earnItChildGoalList.count) {
                self.indexObject = self.earnItChildGoalList.count-1
            }
        }
        self.changeGoalValues(indexx: self.indexObject)
    }
    
    //MARK: Select Operation
    
    @IBAction func dropdownButton_Tap(_ sender: Any) {
//        self.pickerViewSetup()
    }

    func pickerViewSetup() {
//         goalPicker = UIPickerView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:216))
        self.goalPicker.dataSource = self
        self.goalPicker.delegate = self
        self.goalPicker.backgroundColor = UIColor.white
        
        //ToolBar
        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = .default
        pickerToolBar.isTranslucent = true
        pickerToolBar.sizeToFit()
        
        //Adding ToolBar Button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target:self , action: #selector(self.pickerViewDoneButton_Tap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolBar.setItems([spaceButton, doneButton], animated: false)
        pickerToolBar.isUserInteractionEnabled = true
        self.activeField = self.tfOperation
        self.activeField?.inputAccessoryView = pickerToolBar
        self.activeField?.inputView = goalPicker
        if activeField == self.tfOperation {
            goalPicker.selectRow(arrayPickerSelection.index(of: "Add")!, inComponent: 0, animated: false)
//            goalPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }

    func pickerViewDoneButton_Tap() {
        activeField = nil
        activeField?.resignFirstResponder()
        self.view.endEditing(true)
    }

    //MARK: TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
        if textField == self.tfOperation  {
//            self.hideRepeatTasksTable()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        if textField == self.tfOperation {
            self.pickerViewSetup()
         }
        return true
    }
    
    //MARK: Action Methods
    
    @IBAction func viewGotTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButton_Tap(_ sender: Any) {
        if self.isActiveUserChild == true {            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
            self.present(childDashBoard, animated: true, completion: nil)
        }
        else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
            let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
            let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
            
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            slideMenuController.delegate = parentLandingPage
            
            self.present(slideMenuController, animated:false, completion:nil)
        }
    }
    
    @IBAction func saveButton_Tap(_ sender: Any) {
        self.view.endEditing(true)
        if (self.tfAdjustBalance?.text?.count)! == 0  {
            self.view.makeToast("Please input adjustment amount.")
            return
        }
        var strOperationMode:String!
        if (self.tfOperation?.text == "Add") {
            strOperationMode = ""
        }
        else {
            strOperationMode = "-"
        }
        callAdjustBalanceApiForUser(amount: Int((self.tfAdjustBalance?.text)!)!, strReason: self.tvAdjustmentReason?.text, strOperation: strOperationMode!, idGoal: self.objChildGoal.id! , success: {
            (responseJSON) ->() in
            self.hideLoadingView()
            NotificationCenter.default.post(name: Notification.Name("getGoalList_UserData"), object: nil)
            self.dismiss(animated: true, completion: nil)
            /*if (responseJSON["message"][0].stringValue == "Mail sent."){
                self.dismiss(animated: true, completion: nil)
            }
            else if (responseJSON["code"][0] == 9001) {
                //let alert = showAlertWithOption(title: "This email is not associated and an EarnIt! account, please try again.", message: "")
                let alert = showAlertWithOption(title: "Sorry, we don't have that username or account in our system.Please verify the information or contact support at\nsupport@myearnitapp.com", message: "")
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = showAlertWithOption(title: "This email is not associated and an EarnIt! account, Failed to send password, please try again!", message: "")
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }*/
        }) { (error) -> () in
            self.view.makeToast("Failed to adjust balance request, please try again!")
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func userImageViewGotTapped(_ sender: UITapGestureRecognizer) {
        
        return
        
        var childOptionView = (Bundle.main.loadNibNamed("ChildOptionView", owner: self, options: nil)?[0] as? ChildOptionView)!
        var optionView  = (Bundle.main.loadNibNamed("OptionView", owner: self, options: nil)?[0] as? OptionView)!
    
        optionView.center = self.view.center
        optionView.userImageView.image = self.userImageView.image
        optionView.frame.origin.y = self.userImageView.frame.origin.y
        optionView.frame.origin.x = self.view.frame.origin.x + 160
        
        childOptionView.center = self.view.center
        childOptionView.userImageView.image = self.userImageView.image
        childOptionView.frame.origin.y = self.userImageView.frame.origin.y
        childOptionView.frame.origin.x = self.view.frame.origin.x + 160
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 480:
                childOptionView.frame.origin.x = self.view.frame.origin.x + 160
                optionView.frame.origin.x = self.view.frame.origin.x + 160
                
            case 960:
                childOptionView.frame.origin.x = self.view.frame.origin.x + 160
                optionView.frame.origin.x = self.view.frame.origin.x + 160
                
            case 1136:
                childOptionView.frame.origin.x = self.view.frame.origin.x + 100
                optionView.frame.origin.x = self.view.frame.origin.x + 100
                
            case 1334:
                childOptionView.frame.origin.x = self.view.frame.origin.x + 160
                optionView.frame.origin.x = self.view.frame.origin.x + 160
                
            case 2208:
                childOptionView.frame.origin.x = self.view.frame.origin.x + 200
                optionView.frame.origin.x = self.view.frame.origin.x + 200
                
            default:
                print("unknown")
            }
            
        }
        else if  UIDevice().userInterfaceIdiom == .pad {
            
            childOptionView.frame.origin.x = self.view.frame.origin.x + 200
            optionView.frame.origin.x = self.view.frame.origin.x + 200
        }
        if self.isActiveUserChild == true {
            
            childOptionView.firstOption.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
            childOptionView.secondOption.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
            childOptionView.thirdOption.setImage(EarnItImage.setEarnItLogoutIcon(), for: .normal)
            //optionView.sixthOption.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
            
            childOptionView.firstOption.setTitle("View Tasks", for: .normal)
            childOptionView.secondOption.setTitle("Balances", for: .normal)
            childOptionView.thirdOption.setTitle("Logout", for: .normal)
            childOptionView.doActionForFirstOption = {
                self.removeActionView()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
                self.present(childDashBoard, animated: true, completion: nil)
            }
            childOptionView.doActionForSecondOption = {
                self.removeActionView()
            }
            childOptionView.doActionForThirdOption = {
                
                self.removeActionView()
                let keychain = KeychainSwift()
                keychain.delete("isActiveUser")
                keychain.delete("email")
                keychain.delete("password")

                keychain.delete("isProfileUpdated")
                keychain.delete("token")

                //keychain.delete("token")
                //self.stopTimerForFetchingUserDetail()
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
                self.present(loginController, animated: false, completion: nil)
            }
            self.actionView.addSubview(childOptionView)
            self.actionView.backgroundColor = UIColor.clear
            self.view.addSubview(self.actionView)
            
        }
        else {
            optionView.firstOption.setImage(EarnItImage.setEarnItAddIcon(), for: .normal)
            optionView.secondOption.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
            optionView.thirdOption.setImage(EarnItImage.setEarnItAppShowTaskIcon(), for: .normal)
            optionView.forthOption.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
            optionView.fifthOption.setImage(EarnItImage.setEarnItGoalIcon(), for: .normal)
            optionView.sixthOption.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
            optionView.btnAppsMonitorOption.setImage(EarnItImage.setEarnItAppShowTaskIcon(), for: .normal)

            optionView.firstOption.setTitle(MENU_ADD_TASKS, for: .normal)
            optionView.secondOption.setTitle(MENU_ALL_TASKS, for: .normal)
            optionView.thirdOption.setTitle(MENU_APPROVE_TASKS, for: .normal)
            optionView.forthOption.setTitle(MENU_BALANCES, for: .normal)
            optionView.fifthOption.setTitle(MENU_GOALS, for: .normal)
            optionView.sixthOption.setTitle(MENU_MESSAGE, for: .normal)
            optionView.btnAppsMonitorOption.setTitle(MENU_APPS_MONITOR, for: .normal)

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
                print("self.selectedChildUser");
                
                getGoalsForChild(childId : self.earnItChildUser.childUserId,success: {
                    (earnItGoalList) ->() in
                    
                    //print("GOAL", earnItGoalList.count);
                    // print(earnItGoalList);
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                    let addGoalVC = storyBoard.instantiateViewController(withIdentifier: "VCAddDeleteGoal") as! VCAddDeleteGoal
                    
                    if(self.earnItChildUser.earnItGoal.name == "" || self.earnItChildUser.earnItGoal.name == nil){
                        addGoalVC.IS_ADD = true
                    }else {
                        
                        addGoalVC.IS_ADD = false
                    }
                    addGoalVC.IS_ADD = false
                    addGoalVC.earnItChildUser = self.earnItChildUser
                    addGoalVC.earnItChildUsers = self.earnItChildUsers
                    self.present(addGoalVC, animated:true, completion:nil)
                })
                { (error) -> () in
                    
                    let alert = showAlertWithOption(title: "Opps, Please try it again later.", message: "")
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            optionView.doActionForFourthOption = {
                self.removeActionView()
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
            optionView.doActionForButtonAppsMonitorOption = {
                self.removeActionView()
                self.goToAppsMonitorScreen()
            }
        }
    }
    
    //MARK: Picker View Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.arrayPickerSelection.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrayPickerSelection[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //self.lblTotalAccountBalance.text = self.arrayPickerSelection[row]
        self.tfOperation?.text = self.arrayPickerSelection[row]
    }
    
    //MARK: TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = textView
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }

    //MARK: Keyboard Notification
    
    func keyboardWillShow(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        if let activeField = self.activeField {
            let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height+100, 0.0)
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= keyboardSize!.height
            
            if (!aRect.contains(activeField.frame.origin)){
            }
        }
        if let activeTextView = self.activeTextView {
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height+200, 0.0)
            var aRect : CGRect = self.view.frame
            aRect.size.height -= keyboardSize!.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        self.view.endEditing(true)
    }
    
}
