//
//  TaskViewController.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/12/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import Material
import KeychainSwift

class TaskViewController: UIViewController, UIPickerViewDelegate , UIPickerViewDataSource , UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate{
 
    @IBOutlet var taskNameField: UITextField!
    
    @IBOutlet var applyToGoalField: UITextField!

    @IBOutlet var assignToField: UITextField!
    
    @IBOutlet var ammountField: UITextField!
    
    @IBOutlet var taskDetailField: UITextView!
    
    @IBOutlet var requiresPhotoOption: UIButton!
    
    @IBOutlet var repeatsField: UITextField!
    
    @IBOutlet var cancelButton: UIButton!
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var topBannerLabel: UILabel!
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var dateTextField: UITextField!
    
    @IBOutlet var userView: UIView!
    
    @IBOutlet var dueDateLabel: UILabel!
    
    @IBOutlet var calendarImage: UIImageView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField:UITextField?
    var activeTextView:UITextView?
    let repeatTasks = ["None","Daily","Weekly","Monthly"]
    
    var constX:NSLayoutConstraint?
    var constY:NSLayoutConstraint?
    
    var earnItChildGoalList = [EarnItChildGoal]()
    
    var goalPicker = UIPickerView()
    
    var dueDateTimeStamp : String!
    
    var childId : Int!
    
    var allowance : Int!
    
    var createdDateTimeStamp : Int = 0
    
    var taskDetailString : String!
    
    var status : String!
    
    var updateDateTimeStamp : Int = 0
    
    var earnItChildUsers = [EarnItChildUser]()
    
    var earnItChildUserId : Int = 0
    
    var earnItChildUser = EarnItChildUser()
    
    var dueDate = NSDate()
    
    var ammountIsValid : Bool = true
    
    var isPhotoRequired = 0
   
    var selectedGoal =  EarnItChildGoal()
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var btnApprovalTick: UIButton!
    @IBOutlet var btnDelete: UIButton!
    var completedTask = EarnItTask()

    //keyboardOffset
    var currentKeyboardOffset : CGFloat = 0.0
    
    let datePickerHolder = DateTimePicker()
    
    var isInEditingMode = false
    
    var earnItTaskToEdit = EarnItTask()
    
    var createdDate = Date()
    
    var updatedDate = Date()
    
    var actionView = UIView()
    
    var messageView = MessageView()

    @IBOutlet var lblRepeats: UILabel!
    @IBOutlet var ivDropDownRepeat: UIImageView!

    //MARK: View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completedTask = self.earnItTaskToEdit
        self.lblRepeats.isHidden = true
        self.repeatsField.isHidden = true
        self.lblRepeats.isHidden = false
        self.repeatsField.isHidden = false
        self.repeatsField.isUserInteractionEnabled = false
        self.ivDropDownRepeat.isHidden = true
        self.btnApprovalTick.isHidden = true
        self.btnDelete.isHidden = true

        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGesture)
        
        self.messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?[0] as? MessageView)!
        //
        self.messageView.center = CGPoint(x: self.view.center.x,y :self.view.center.y-80)
        self.messageView.messageText.delegate = self
        
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchParentUserDetailFromBackground), userInfo: nil, repeats: true)
        self.dateTextField.delegate = self
        self.taskDetailField.delegate = self
        self.requestObserver()
        self.setUpUserInfoView()
        //self.getGoalListForCurrentUser()
        self.setUpEditViewForUser()
        self.addButtonsOnKeyboard()
        //self.datePickerHolder.timePicker.addTarget(self, action: #selector(self.fetchDateFromSelectedDate(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getGoalListForCurrentUser()
        self.messageView.messageToLabel.text = "Message to  \(self.earnItChildUser.firstName!):"
    }
    
    func pickerViewSetup()  {
        //UIPickerView
       // goalPicker = UIPickerView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:216))
        goalPicker.dataSource = self
        goalPicker.delegate = self
        goalPicker.backgroundColor = UIColor.white
        
        //ToolBar
        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = .default
        pickerToolBar.isTranslucent = true
        pickerToolBar.sizeToFit()
        
        //Adding ToolBar Button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target:self , action: #selector(self.repeatTaskDoneButtonClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolBar.setItems([spaceButton,doneButton], animated: false)
        pickerToolBar.isUserInteractionEnabled = true
        activeField?.inputAccessoryView = pickerToolBar
        activeField?.inputView = goalPicker
        
        if activeField == repeatsField {
            goalPicker.selectRow(repeatTasks.index(of: repeatsField.text!)!, inComponent: 0, animated: false)
        }
        else if activeField == applyToGoalField && activeField?.text != "None" {
            var tempSelectedGoal = EarnItChildGoal()
            tempSelectedGoal.id = 0
            
            for goal in earnItChildGoalList {
                
                print(goal.id!)
                if goal.id! == self.selectedGoal.id! {
                    
                    tempSelectedGoal = goal
                    break
                }
            }
            
            if tempSelectedGoal.id != 0 {
                goalPicker.selectRow(earnItChildGoalList.index(of: tempSelectedGoal)!, inComponent: 0, animated: false)
            }
            else {
                goalPicker.selectRow(0, inComponent: 0, animated: false)
            }
        }
        else {
            goalPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
   
    func repeatTaskDoneButtonClicked() {
        activeField?.resignFirstResponder()
    }
    
    @IBAction func amountValueDidChange(_ sender: UITextField) {
        if sender == self.ammountField {
            
            if sender.text?.isNumber == false {
                
                self.ammountIsValid = false
            }else{
                self.ammountIsValid = true
            }
        }
    }
    
    //MARK: Void Methods
    
    func gotoCalenderView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let calendarView = storyBoard.instantiateViewController(withIdentifier: "VCCalendar") as! VCCalendar
        calendarView.earnItChildUser = self.earnItChildUser
        self.present(calendarView, animated: false, completion: nil)
    }
    
    //MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
        //        if textField == repeatsField  {
        //            self.hideRepeatTasksTable()
        //        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        if textField == repeatsField || textField == applyToGoalField  {
            self.pickerViewSetup()
        }
        return true
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
    
    //MARK: -UIPickerView Datasource & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if activeField == repeatsField {
            return self.repeatTasks.count
        }
        else  {
            return self.earnItChildGoalList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activeField == repeatsField {
            return self.repeatTasks[row]
        }
        else  {
            return earnItChildGoalList[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if activeField == repeatsField {
            repeatsField.text = repeatTasks[row]
        }
        else  {
            applyToGoalField.text = earnItChildGoalList[row].name
            self.selectedGoal = earnItChildGoalList[row]
        }
    }

     // *Override
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        if textField == self.ammountField || textField == self.applyToGoalField{
    
        let text = (textField.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        if let regex = try? NSRegularExpression(pattern: "^[0-9]{0,6}((\\.)[0-9]{0,2})?$", options: .caseInsensitive) {
            
            return regex.numberOfMatches(in: newText, options: .reportProgress, range: NSRange(location: 0, length: (newText as NSString).length)) > 0
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
          }
          return false
            
        }else if textField == self.taskNameField{
            
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 40
        }
        return true
  }
    
    func setUpUserInfoView(){
        for user in self.earnItChildUsers{
            if user.childUserId == self.earnItChildUserId{
                self.earnItChildUser = user
                //let userAvatarUrlString = user.childUserImageUrl
                self.assignToField.text = user.firstName
                //self.topBannerLabel.text = self.topBannerLabel.text! + " " + user.firstName
                if (EarnItAccount.currentUser.firstName != nil) {
                    self.topBannerLabel.text = "Hi" + " " + EarnItAccount.currentUser.firstName
                }
                else {
                    self.topBannerLabel.text = "Hi" + " " + self.earnItChildUser.firstName!
                }
                self.lblSubtitle.text = user.firstName
                self.selectedGoal.name = "None"
                
                self.userImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX + user.childUserImageUrl!)
//                let url = URL(string: userAvatarUrlString!)
              
//                if url != nil{
//                    
//                    let data = try? Data(contentsOf: url!)
//                    
//                    if let imageData = data {
//                        
//                        self.userImageView.image = UIImage(data: data!)
//                        self.assignToField.text = user.firstName
//                        self.topBannerLabel.text = self.topBannerLabel.text! + " " + user.firstName
//                        self.selectedGoal.name = "None"
//
//                    }
//                    
//                }else{
//           
//                    self.userImageView.image = EarnItImage.defaultUserImage()
//                    self.assignToField.text = user.firstName
//                    self.topBannerLabel.text = self.topBannerLabel.text! + " " + user.firstName
//                    self.selectedGoal.name = "None"
//                }
//             
            }
        }
    }
    
    func getGoalListForCurrentUser(){
        self.showLoadingView()
        getGoalsForChild(childId : self.earnItChildUserId,success: {
            
            (earnItGoalList) ->() in
            
            self.earnItChildGoalList = [EarnItChildGoal]()
            let earnItGoalForNone = EarnItChildGoal()
            earnItGoalForNone.name = "None"
            earnItGoalForNone.id = 0
            self.earnItChildGoalList.append(earnItGoalForNone)
            for earnItGoal in earnItGoalList{
                if earnItGoal.id != 0 {
                    self.earnItChildGoalList.append(earnItGoal)
                }
            }
            self.hideLoadingView()
        })
            
        { (error) -> () in
            
            let alert = showAlertWithOption(title: "Get goal list failed ", message: "")
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.hideLoadingView()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setUpEditViewForUser(){
        if self.isInEditingMode == true{
            if (EarnItAccount.currentUser.firstName != nil) {
                self.topBannerLabel.text = "Hi" + " " + EarnItAccount.currentUser.firstName
            }
            else {
                self.topBannerLabel.text = "Hi" + " " + self.earnItChildUser.firstName!
            }
            self.lblSubtitle.text = self.earnItTaskToEdit.taskName
            self.selectedGoal.name = self.earnItTaskToEdit.goal.name
            self.taskNameField.text = self.earnItTaskToEdit.taskName
            self.selectedGoal.id = self.earnItTaskToEdit.goal.id
            self.selectedGoal = self.earnItTaskToEdit.goal
            
            if self.earnItTaskToEdit.goal.name == " " || self.earnItTaskToEdit.goal.name == nil{
                self.applyToGoalField.text = "None"
            }else {
                self.applyToGoalField.text = self.earnItTaskToEdit.goal.name
            }
            self.ammountField.text = String(Double(round(1000 * self.earnItTaskToEdit.allowance)/1000))
            self.taskDetailField.text = self.earnItTaskToEdit.taskDescription
            self.dueDateLabel.text = getDueDateAndTime(dueDate: self.earnItTaskToEdit.dueDate)
            self.saveButton.setTitle("Update", for: .normal)
            self.btnApprovalTick.isHidden = false
            self.btnDelete.isHidden = false
            self.isPhotoRequired  = self.earnItTaskToEdit.isPictureRequired
            self.dueDate = self.earnItTaskToEdit.dueDate as NSDate
            self.createdDate = Date(milliseconds: self.earnItTaskToEdit.createdDateTimeStamp)
            self.updatedDate = Date()
            if ( self.isPhotoRequired  == 0 ){
                self.requiresPhotoOption.setImage(nil, for: .normal)
                self.requiresPhotoOption.backgroundColor = UIColor.clear
                self.isPhotoRequired = 0
           
            }else if (self.isPhotoRequired == 1){
                
                self.requiresPhotoOption.setImage(Icon.check, for: .normal)
                self.requiresPhotoOption.backgroundColor = UIColor.white
                self.isPhotoRequired = 1
            }
            var i = 0
            switch   self.earnItTaskToEdit.repeatMode {
            case .Daily:
                i = 1
            case .Weekly:
                i = 2
            case .Monthly:
                i = 3
                
            default:
                i = 0
            }
            repeatsField.text = repeatTasks[i]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerCancelPressed(){
        self.view.endEditing(true)
    }
    
    func fetchDateFromSelectedDate(_ sender: UIDatePicker) {
        print("fetchDateFromSelectedDate....")
        self.dueDate = sender.date as NSDate
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dueTime = formatter.string(from: self.dueDate  as Date)
        formatter.dateFormat = "M/dd"
        let dateMonthString = formatter.string(from: self.dueDate  as Date)
        self.dueDateLabel.text = dateMonthString + " @ " + dueTime
    }
    
    // MARK: - NonSpecific User Functions
    
    /**
     Creates request for keyboardWillShow
     
     - Parameters:
     
     - nil
     */
    
    private func requestObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(TaskViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TaskViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide  , object: nil)
    }
    
    /**
     Responds to keyboard showing and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
//    func keyboardWillShow(_ notification:NSNotification){
//        
//        let info = notification.userInfo!
//        let keyboardHeight: CGFloat = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
//        
//        
//        if UIDevice().userInterfaceIdiom == .phone {
//            
//        switch UIScreen.main.nativeBounds.height {
//                
//        case 2208:
//        
//        let keyboardYValue = self.view.frame.height - keyboardHeight
//     
//        
//                if self.dateTextField.isFirstResponder {
//                    
//                    let dateTextFieldYValue = self.saveButton.frame.size.height + self.saveButton.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (dateTextFieldYValue ) > keyboardYValue - 20.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - dateTextFieldYValue + 100
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
//                
//        }else if self.taskDetailField.isFirstResponder {
//            
//            print("self.taskDetailField.isFirstResponder")
//            let taskDetailFieldYValue = self.saveButton.frame.size.height + self.saveButton.frame.origin.y
//            
//            if self.currentKeyboardOffset == 0.0 {
//                
//                if (taskDetailFieldYValue ) > keyboardYValue + 20.0 {
//                    
//                    self.currentKeyboardOffset = (keyboardYValue + 50.0) - taskDetailFieldYValue +  160
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
//                    }
//            
//            
//            }
//                else if self.ammountField.isFirstResponder {
//                    
//                    print("self.taskDetailField.isFirstResponder")
//                    let taskDetailFieldYValue = self.saveButton.frame.size.height + self.saveButton.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (taskDetailFieldYValue ) > keyboardYValue + 20.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - taskDetailFieldYValue +  160
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
//                    
//            }
//            
//        case 1136:
//            
//            
//            let keyboardYValue = self.view.frame.height - keyboardHeight
//            
//            
//            if self.dateTextField.isFirstResponder {
//                
//                let dateTextFieldYValue = self.dateTextField.frame.size.height + self.dateTextField.frame.origin.y
//                
//                if self.currentKeyboardOffset == 0.0 {
//                    
//                    if (dateTextFieldYValue ) > keyboardYValue + 10.0 {
//                        
//                        self.currentKeyboardOffset = (keyboardYValue + 50.0) - dateTextFieldYValue + 270
//                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                            self.view.frame.origin.y -= self.currentKeyboardOffset
//                            
//                        }, completion: { (completed) -> Void in
//                            
//                            
//                        })
//                        
//                    }
//                    
//                }
//                
//                
//            }else if self.taskDetailField.isFirstResponder {
//                
//                print("self.taskDetailField.isFirstResponder")
//                let taskDetailFieldYValue = self.saveButton.frame.size.height + self.saveButton.frame.origin.y
//                
//                if self.currentKeyboardOffset == 0.0 {
//                    
//                    if (taskDetailFieldYValue ) > keyboardYValue + 20.0 {
//                        
//                        self.currentKeyboardOffset = (keyboardYValue + 50.0) - taskDetailFieldYValue + 360
//                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                            self.view.frame.origin.y -= self.currentKeyboardOffset
//                            
//                        }, completion: { (completed) -> Void in
//                            
//                            
//                        })
//                        
//                    }
//                    
//                    
//                }
//                
//            }else if self.ammountField.isFirstResponder {
//                
//                print("self.taskDetailField.isFirstResponder")
//                let taskDetailFieldYValue = self.saveButton.frame.size.height + self.saveButton.frame.origin.y
//                
//                if self.currentKeyboardOffset == 0.0 {
//                    
//                    if (taskDetailFieldYValue ) > keyboardYValue + 20.0 {
//                        
//                        self.currentKeyboardOffset = (keyboardYValue + 50.0) - taskDetailFieldYValue  + 360
//                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                            self.view.frame.origin.y -= self.currentKeyboardOffset
//                            
//                        }, completion: { (completed) -> Void in
//                            
//                            
//                        })
//                        
//                    }
//                    
//                    
//                }
//                
//            }
//            
//        default:
//            
//            
//            let keyboardYValue = self.view.frame.height - keyboardHeight
//            
//            
//            if self.dateTextField.isFirstResponder {
//                
//                let dateTextFieldYValue = self.dateTextField.frame.size.height + self.dateTextField.frame.origin.y
//                
//                if self.currentKeyboardOffset == 0.0 {
//                    
//                    if (dateTextFieldYValue ) > keyboardYValue + 10.0 {
//                        
//                        self.currentKeyboardOffset = (keyboardYValue + 50.0) - dateTextFieldYValue + 150
//                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                            self.view.frame.origin.y -= self.currentKeyboardOffset
//                            
//                        }, completion: { (completed) -> Void in
//                            
//                            
//                        })
//                        
//                    }
//                    
//                }
//                
//                
//            }else if self.taskDetailField.isFirstResponder {
//                
//                print("self.taskDetailField.isFirstResponder")
//                let taskDetailFieldYValue = self.saveButton.frame.size.height + self.saveButton.frame.origin.y
//                
//                if self.currentKeyboardOffset == 0.0 {
//                    
//                    if (taskDetailFieldYValue ) > keyboardYValue + 20.0 {
//                        
//                        self.currentKeyboardOffset = (keyboardYValue + 50.0) - taskDetailFieldYValue +  250
//                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                            self.view.frame.origin.y -= self.currentKeyboardOffset
//                            
//                        }, completion: { (completed) -> Void in
//                            
//                            
//                        })
//                        
//                    }
//  
//            
//                }
//            
//            }else if self.ammountField.isFirstResponder {
//                
//                print("self.taskDetailField.isFirstResponder")
//                let taskDetailFieldYValue = self.saveButton.frame.size.height + self.saveButton.frame.origin.y
//                
//                if self.currentKeyboardOffset == 0.0 {
//                    
//                    if (taskDetailFieldYValue ) > keyboardYValue + 20.0 {
//                        
//                        self.currentKeyboardOffset = (keyboardYValue + 50.0) - taskDetailFieldYValue +  250
//                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                            self.view.frame.origin.y -= self.currentKeyboardOffset
//                            
//                        }, completion: { (completed) -> Void in
//                            
//                            
//                        })
//                        
//                    }
//                    
//                    
//                }
//                
//            }
//            
//        }
//            
//      }
//    
//    }
    

    
    
    /**
     Responds to keyboard hiding and adjusts the scrollview.
     
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
            
            let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height+100, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect : CGRect = self.view.frame
            aRect.size.height -= keyboardSize!.height
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        if let activeTextView = self.activeTextView {
            
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height+200, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect : CGRect = self.view.frame
            aRect.size.height -= keyboardSize!.height
//            if (!aRect.contains(activeTextView.frame.origin)){
                self.scrollView.scrollRectToVisible(activeTextView.frame, animated: true)
        //    }
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        // self.scrollView.isScrollEnabled = false
    }
    
    @IBAction func viewGotTapped(_ sender: Any) {
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
    
    @IBAction func callSaveTaskApiBasedOnValidation(_ sender: Any) {
        print("self.ammountField.text \(self.ammountField.text)")
        self.view.endEditing(true)

        self.showLoadingView()
        let earnItTask = EarnItTask()
        earnItTask.taskName = self.taskNameField.text

        earnItTask.createdDateTimeStamp = self.createdDate.millisecondsSince1970
        earnItTask.updateDateTimeStamp = self.updatedDate.millisecondsSince1970
        earnItTask.dueDateTimeStamp = self.dueDate.millisecondsSince1970
        
        earnItTask.taskComments = []
        earnItTask.isPictureRequired = self.isPhotoRequired
        earnItTask.taskDescription = self.taskDetailField.text
        
        switch repeatsField.text! {
        case "None":
            earnItTask.repeatMode = .None
        case "Daily":
            earnItTask.repeatMode = .Daily
        case "Weekly":
                earnItTask.repeatMode = .Weekly
        case "Monthly":
            earnItTask.repeatMode = .Monthly
            
        default:
            earnItTask.repeatMode = .None
        }
        
        if (self.taskNameField.text?.characters.count)! > 0 && self.taskNameField.text?.isEmptyField == false  {
            
            if (self.ammountField.text?.isEmptyField)! {
                
                 earnItTask.allowance = Double(0)
                
            }else{
            
            earnItTask.allowance = Double(self.ammountField.text!)
            
            }
            if (dueDateLabel.text?.isEmpty)! {
                self.hideLoadingView()
                self.view.makeToast("Please select a due date for the task")
                return
            }
            if self.isInEditingMode == true {
                self.callEditTask(earnItTask: earnItTask)
            }else {
                self.callAddTask(earnItTask: earnItTask)
            }
        }else{
                self.hideLoadingView()
                self.view.makeToast("Please complete the Task Name ")
        }
    }
        
      func callEditTask(earnItTask: EarnItTask){
        print("Calling edit task")
        earnItTask.status = self.earnItTaskToEdit.status
        earnItTask.taskId = self.earnItTaskToEdit.taskId
        earnItTask.repeatScheduleDic = self.earnItTaskToEdit.repeatScheduleDic
            if self.selectedGoal.name == "None"{
                earnItTask.goal.id = nil
            }else {
                earnItTask.goal.id = self.selectedGoal.id
           }
            callApiForUpdateTaskByParent(earnItTaskChildId:self.earnItChildUserId ,earnItTask: earnItTask, success: {_ in
               self.dismiss(animated: true, completion: nil)
            }) { (error) -> () in
                self.hideLoadingView()
                self.view.makeToast("update Failed")
//                let alert = showAlert(title: "Error", message: "Failed")
//                self.present(alert, animated: true, completion: nil)
            }
      }
    
        func callAddTask(earnItTask : EarnItTask) {
            //print("Calling add task")
            earnItTask.status = TaskStatus.created

            addTaskForChild(childId : self.earnItChildUserId,earnItTask: earnItTask,earnItSelectedGoal: self.selectedGoal ,success: {
                (responseJSON) ->() in
                self.hideLoadingView()
                //self.dismiss(animated: true, completion: nil)
                let alert = showAlertWithOption(title: "Task added", message: "Do you want to add another task?")
                
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.setForNewTask))
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: self.dismissView))
                self.present(alert, animated: true, completion: nil)
            })
                
            { (error) -> () in
                self.hideLoadingView()
                self.view.makeToast("Add task failed")
//                let alert = showAlertWithOption(title: "Add task failed ", message: "")
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
            }
    }
    
    func dismissView(alert: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
        self.repeatsField.text = repeatTasks[0]
    }
    
    func setForNewTask(alert: UIAlertAction) {
        self.view.endEditing(true)
        self.taskNameField.text = ""
        self.taskDetailField.text = ""
        self.ammountField.text = ""
        let earnItTask = EarnItTask()
        self.createdDate = Date()
        self.updatedDate = Date()
        self.dueDate = Date() as NSDate
        self.dueDateLabel.text = ""
        self.repeatsField.text = repeatTasks[0]
        //self.applyToGoalField.text = "None"
        
        self.isPhotoRequired = 0
        self.requiresPhotoOption.setImage(nil, for: .normal)
        self.requiresPhotoOption.backgroundColor = UIColor.clear
        self.datePickerHolder.timePicker.setDate(Date(), animated: true)
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
                if (responseJSON["email"].string == nil || responseJSON["email"].stringValue == ""){
                    self.dismissScreenToLogin()
                }
                else {
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
                }
            }) { (error) -> () in
                 self.dismissScreenToLogin()
                
//                let alert = showAlertWithOption(title: "Authentication failed", message: "please login again")
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreenToLogin))
//                self.present(alert, animated: true, completion: nil)
                
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
    
    //MARK: API Update Task Methods
    
    func setStatusAndCallApiForUpdateTask(taskStatus: String){
        self.showLoadingView()
        if self.isInEditingMode != true{
            return
        }
        self.completedTask.status = taskStatus
        callApiForUpdateTask(earnItTaskChildId:self.earnItChildUser.childUserId ,earnItTask:self.completedTask, success: {_ in
            
            var updatedTaskList = [EarnItTask]()
            for task in self.earnItChildUser.earnItTasks {
                if task.taskId == self.completedTask.taskId{
                    task.status = self.completedTask.status
                }
                updatedTaskList.append(task)
            }
            self.earnItChildUser.earnItTasks = updatedTaskList
            self.hideLoadingView()
            self.showNextApprovalTask()
        }) { (error) -> () in
            self.view.makeToast("Failed")
            self.hideLoadingView()
        }
    }
    
    func showNextApprovalTask() {
        /*for task in  self.earnItChildUser.earnItTasks {
            if task.status == TaskStatus.completed {
                self.completedTask = task
                self.assignTaskDetails()
                return
            }
        }*/
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Action Methods
    
    @IBAction func showDatePicker(_ sender: Any) {
        //Calendar View Navigation
        /*self.view.endEditing(true)
         self.gotoCalenderView()
         return*/
        print("showDatePicker")
        self.dateTextField.inputView = datePickerHolder
        datePickerHolder.setSelectedDate =  {
            print("didDateSelectedFromPicker")
            self.fetchDateFromSelectedDate(self.datePickerHolder.timePicker)
            self.view.endEditing(true)
        }
        datePickerHolder.closeDatePicker = {
            print("closeDatePicker")
            self.view.endEditing(true)
        }
        self.datePickerHolder.timePicker.minimumDate = Date()
        self.datePickerHolder.timePicker.setDate(self.dueDate as Date, animated: true)
    }
    
    @IBAction func showSideMenu(_ sender: Any) {
        print("Opening slideview")
        self.openRight()
    }
    
    @IBAction func photoRequiresButtonClicked(_ sender: UIButton) {
        if ( isPhotoRequired  == 0 ){
            self.requiresPhotoOption.setImage(Icon.check, for: .normal)
            self.requiresPhotoOption.backgroundColor = UIColor.white
            isPhotoRequired = 1
            
        }else if (isPhotoRequired == 1){
            self.requiresPhotoOption.setImage(nil, for: .normal)
            self.requiresPhotoOption.backgroundColor = UIColor.clear
            isPhotoRequired = 0
        }
    }

    @IBAction func goBackToParentLandingPage(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
        /* let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
         let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
         let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, rightMenuViewController: optionViewController)
         slideMenuController.automaticallyAdjustsScrollViewInsets = true
         slideMenuController.delegate = parentLandingPage
         self.present(slideMenuController, animated: true, completion:nil)*/
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func btnApprovalTask_Tapped(_ sender: Any) {
        self.view.endEditing(true)
        let alert = showAlertWithOption(title: "Are you sure you want to approve this task? Any credit towards this task will be applied.", message: "")
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.instaneApprovalForTask))
        self.present(alert, animated: true, completion: nil)
    }
    
    func instaneApprovalForTask(_ sender: Any) {
        print("Instant Approval")
//        self.dismiss(animated: true, completion: nil)        
        self.completedTask.status = TaskStatus.closed
        self.setStatusAndCallApiForUpdateTask(taskStatus: TaskStatus.closed)
    }
    
    @IBAction func btnDelete_Tapped(_ sender: Any) {
        self.view.endEditing(true)
        let alert = showAlertWithOption(title: "Are you sure you want to delete this task?", message: "")
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.deleteTask))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteTask(_ sender: Any) {
        print("Delete Task")
        self.dismiss(animated: true, completion: nil)
        
        /*return
        self.completedTask.status = TaskStatus.rejected
        self.setStatusAndCallApiForUpdateTask(taskStatus: TaskStatus.rejected)
         */
    }
    
    @IBAction func calendarImageTapped(_ sender: Any) {
        self.dateTextField.becomeFirstResponder()
    }
    
    @IBAction func userImageGotTapped(_ sender: UITapGestureRecognizer) {
        let optionView  = (Bundle.main.loadNibNamed("OptionView", owner: self, options: nil)?[0] as? OptionView)!
        optionView.center = self.view.center
        optionView.userImageView.image = self.userImageView.image
        optionView.frame.origin.y = self.userImageView.frame.origin.y + 20
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
            if self.earnItChildUser.earnItTasks.count  > 0 {
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
            taskViewController.earnItChildUserId = self.earnItChildUserId
            taskViewController.earnItChildUsers = self.earnItChildUsers
            self.present(taskViewController, animated:false, completion:nil)
        }
        
        optionView.doActionForFifthOption = {
            
            self.removeActionView()
            print("self.selectedChildUser");
            
            print(self.earnItChildUser);
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
        optionView.doActionForButtonAppsMonitorOption = {
            self.removeActionView()
            self.goToAppsMonitorScreen()
        }
    }
    
    func actionViewDidTapped(_ sender: UITapGestureRecognizer){
        print("actionViewDidTapped..")
        self.removeActionView()
    }
    
    func goToAppsMonitorScreen(){
        //Navigate to Monitoring
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let appsmonitorController = storyBoard.instantiateViewController(withIdentifier: "VCAppsMonitor") as! VCAppsMonitor
        appsmonitorController.earnItChildUsers = self.earnItChildUsers
        self.present(appsmonitorController, animated:true, completion:nil)
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
    
    //MARK: -Keypad Butoons
    func addButtonsOnKeyboard() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonPressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeButtonPressed))
        
        toolBar.setItems([cancelButton,spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.ammountField.inputAccessoryView = toolBar
    }
    
    func nextButtonPressed() {
        self.taskDetailField.becomeFirstResponder()
    }
    
    func closeButtonPressed(){
        self.view.endEditing(true)
    }
    
}

