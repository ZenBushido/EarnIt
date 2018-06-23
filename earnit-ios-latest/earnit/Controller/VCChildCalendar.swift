//
//  VCChildCalendar.swift
//  earnit
//
//  Created by Gaurav on 17/06/18.

import UIKit
import FSCalendar

class VCChildCalendar: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
//    private weak var calendar: FSCalendar!
    @IBOutlet var headerView: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblBarTitle: UILabel!
    @IBOutlet var viewTempCalendar: UIView!
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var userImageView: UIImageView!
    var earnItChildUser =  EarnItChildUser()
    @IBOutlet var dateTextField: UITextField!
    var activeField:UITextField?
    @IBOutlet var tfDay: UITextField!
    @IBOutlet var tfDayCount: UITextField!

    @IBOutlet var vRepeatMain: UIView!
    @IBOutlet var btnRemoveBG: UIButton!
    @IBOutlet var vInsideRepeat: UIView!
    @IBOutlet var btnRepeatEveryMonth: UIButton!
    @IBOutlet var btnEach: UIButton!
    @IBOutlet var btnOnDay: UIButton!
    @IBOutlet var repeatCalendar: FSCalendar!
    @IBOutlet var btnOnDayNumber: UIButton!
    @IBOutlet var btnOnDayName: UIButton!
    var tasksForTheMonth = [EarnItTask]()

//    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var weekPickerView = UIPickerView()
    let arrRepeatTaskDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let arrRepeatTaskCount = ["First", "Second", "Third", "Fourth"]

    //MARK: View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        print(EarnItAccount.currentUser.firstName)
//        self.setupTasksArrayForChildCalendar()
        
        if (EarnItAccount.currentUser.firstName != nil){
            self.lblTitle.text = "\(EarnItAccount.currentUser.firstName!)"
        }
        else {
            self.lblTitle.text = "\(earnItChildUser.firstName!)"
        }
        self.lblBarTitle.text = "Task Schedule" // "Task Due Date"
        self.view.backgroundColor = UIColor.EarnItAppBackgroundColor()
        self.userImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX + self.earnItChildUser.childUserImageUrl!)
        self.dateTextField?.attributedPlaceholder = NSAttributedString(string:"None", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.dateTextField.text = "None"
        self.tfDay?.attributedPlaceholder = NSAttributedString(string:"None", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.tfDayCount?.attributedPlaceholder = NSAttributedString(string:"None", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.tfDay.isUserInteractionEnabled = true
        self.tfDay.text = "Sunday"
        self.tfDay.delegate = self
        self.tfDayCount.isUserInteractionEnabled = true
        self.tfDayCount.text = "First"
        self.tfDayCount.delegate = self
        
        self.setupRepeatView()
        self.setupCalendarView()
//        self.fetchChildAllTasks()
//        /childrens/profile/images
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tasksForTheMonth.removeAll()
        super.viewDidAppear(animated)
    }
    
    func setupCalendarView() {
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.calendar.backgroundColor = UIColor.EarnItAppBackgroundColor()
        //Style the calendar view
        self.calendar.appearance.headerTitleColor = UIColor.white
        self.calendar.appearance.titleDefaultColor = UIColor.white
        self.calendar.appearance.weekdayTextColor = UIColor.white
        self.calendar.appearance.selectionColor = UIColor.clear //UIColor.earnItAppPinkColor()
        self.calendar.appearance.todayColor = UIColor.earnItAppPinkColor()
        self.calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
//         self.calendar.appearance.borderRadius = 1.0
//        self.calendar.appearance.borderDefaultColor = UIColor.earnItAppPinkColor()
        self.calendar.appearance.eventSelectionColor = UIColor.white
    }

    //MARK: Get All Tasks From Server
    
    func fetchChildAllTasks() {
//        self.showLoadingView()
        print("\(earnItChildUser.childUserId)")
        getAllTasksForChild(childId : earnItChildUser.childUserId,success: {
            
            (earnItTaskList) ->() in
            print(earnItTaskList.count)
            /*self.earnItChildGoalList = [EarnItTask]()
            let earnItGoalForNone = EarnItTask()
            earnItGoalForNone.name = "None"
            earnItGoalForNone.id = 0
            self.earnItChildGoalList.append(earnItGoalForNone)
            for earnItGoal in earnItGoalList{
                if earnItGoal.id != 0 {
                    self.earnItChildGoalList.append(earnItGoal)
                }
            }*/
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

    //MARK: Show Loading View
    
    func showLoadingView(){
        self.view.alpha = 0.7
        self.view.isUserInteractionEnabled = false
//        self.activityIndicator.startAnimating()
    }
    
    func hideLoadingView(){
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
//        self.activityIndicator.stopAnimating()
    }

    //MARK: Repeat View Methods
    
    func setupRepeatView() {
        self.vInsideRepeat.layer.cornerRadius = 10
        self.vInsideRepeat.layer.borderWidth = 1.5
        self.vInsideRepeat.layer.borderColor = UIColor.white.cgColor
        self.vInsideRepeat.backgroundColor = UIColor.EarnItAppBackgroundColor()
        
        self.btnRepeatEveryMonth.layer.cornerRadius = 0.5 * self.btnEach.bounds.size.width
        self.btnRepeatEveryMonth.clipsToBounds = true
        self.btnRepeatEveryMonth.backgroundColor = UIColor.clear
        self.btnRepeatEveryMonth.layer.borderColor = UIColor.lightGray.cgColor
        self.btnRepeatEveryMonth.layer.borderWidth = 2

        self.btnEach.layer.cornerRadius = 0.5 * self.btnEach.bounds.size.width
        self.btnEach.clipsToBounds = true
        self.btnEach.backgroundColor = UIColor.clear
        self.btnEach.layer.borderColor = UIColor.lightGray.cgColor
        self.btnEach.layer.borderWidth = 2
        
        self.btnOnDay.layer.cornerRadius = 0.5 * self.btnOnDay.bounds.size.width
        self.btnOnDay.clipsToBounds = true
        self.btnOnDay.backgroundColor = UIColor.clear
        self.btnOnDay.layer.borderColor = UIColor.lightGray.cgColor
        self.btnOnDay.layer.borderWidth = 2
        
        self.repeatCalendar.dataSource = self
        self.repeatCalendar.delegate = self
        self.repeatCalendar.backgroundColor = UIColor.EarnItAppBackgroundColor()
        //Style the calendar view
        self.repeatCalendar.appearance.headerTitleColor = UIColor.white
        self.repeatCalendar.appearance.titleDefaultColor = UIColor.white
        self.repeatCalendar.appearance.weekdayTextColor = UIColor.white
        self.repeatCalendar.appearance.selectionColor = UIColor.earnItAppPinkColor()
        self.repeatCalendar.appearance.todayColor = UIColor.earnItAppPinkColor()
        self.repeatCalendar.isUserInteractionEnabled = false
        self.repeatCalendar.calendarHeaderView.isHidden = true
        self.repeatCalendar.calendarWeekdayView.isHidden = true
        self.repeatCalendar.headerHeight = 0
        self.repeatCalendar.weekdayHeight = 0
        self.vRepeatMain.isHidden = true
//        self.btnOnDayNumber.isUserInteractionEnabled = false
//        self.btnOnDayName.isUserInteractionEnabled = false
    }

    @IBAction func cancel_ButtonTapped(_ sender: Any) {
        self.vRepeatMain.isHidden = true
    }
    
    @IBAction func ok_ButtonTapped(_ sender: Any) {
        self.vRepeatMain.isHidden = true
    }
    
    @IBAction func repeatCheckMarkButtons_Tapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.btnEach.backgroundColor = UIColor.clear
        self.btnOnDay.backgroundColor = UIColor.clear
        self.btnRepeatEveryMonth.backgroundColor = UIColor.clear
        self.btnOnDayNumber.isUserInteractionEnabled = false
        self.btnOnDayName.isUserInteractionEnabled = false
        if (sender.tag == 10) {
//            self.btnRepeatEveryMonth.setImage(UIImage.init(named: "remember_me_checkbox_pink.png"), for: UIControlState.normal)
            self.btnRepeatEveryMonth.backgroundColor = UIColor.earnItAppPinkColor()
        }
        else if (sender.tag == 11) {
            self.btnEach.backgroundColor = UIColor.earnItAppPinkColor()
        }
        else {
            self.btnOnDay.backgroundColor = UIColor.earnItAppPinkColor()
            self.btnOnDayNumber.isUserInteractionEnabled = true
            self.btnOnDayName.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func dayAndDayCountButtons_Tapped(_ sender: UIButton) {
        if (sender.tag == 20) {
            activeField = self.tfDayCount
        }
        else {
            activeField = self.tfDay
        }
        activeField?.becomeFirstResponder()
    }

    //MARK: Repeat Calendar OK Button Action Method

    //MARK: Picker View Methods

    func pickerViewSetup()  {
        //UIPickerView
//         weekDayCountPicker = UIPickerView(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:216))
        weekPickerView.dataSource = self
        weekPickerView.delegate = self
        weekPickerView.backgroundColor = UIColor.white
        //ToolBar
        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = .default
        pickerToolBar.isTranslucent = true
        pickerToolBar.sizeToFit()
        //Adding ToolBar Button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target:self , action: #selector(self.repeatTaskDoneButtonClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolBar.setItems([spaceButton, doneButton], animated: false)
        pickerToolBar.isUserInteractionEnabled = true
        self.activeField?.inputAccessoryView = pickerToolBar
        self.activeField?.inputView = weekPickerView
        if activeField == self.tfDayCount {
            weekPickerView.selectRow(self.arrRepeatTaskCount.index(of: self.tfDayCount.text!)!, inComponent: 0, animated: false)
        }
        else {
            weekPickerView.selectRow(self.arrRepeatTaskDays.index(of: self.tfDay.text!)!, inComponent: 0, animated: false)
        }
//            weekDayCountPicker.selectRow(0, inComponent: 0, animated: false)
    }
    
    func repeatTaskDoneButtonClicked() {
        activeField = nil
        activeField?.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    //MARK: -UIPickerView Datasource & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if activeField == self.tfDayCount {
            return self.arrRepeatTaskCount.count
        }
        else  {
            return self.arrRepeatTaskDays.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activeField == self.tfDayCount {
            return self.arrRepeatTaskCount[row]
        }
        else  {
            return self.arrRepeatTaskDays[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if activeField == self.tfDayCount {
            self.tfDayCount.text = self.arrRepeatTaskCount[row]
        }
        else  {
            self.tfDay.text = self.arrRepeatTaskDays[row]
        }
    }
    
    //MARK: Action Methods
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func saveButtonClicked(_ sender: Any) {

    }

    @IBAction func repeatButtonTapped(_ sender: Any) {
        self.vRepeatMain.isHidden = false
    }

    //MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        if textField == self.tfDayCount || textField == self.tfDay {
            self.pickerViewSetup()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    //MARK: Calendar Delegates Methods

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("date didSelect")
        print(date)
//        dismiss(animated: true, completion: nil)
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        var taskCount = Int()
        var selectedDateTasks = [EarnItTask]()
//        for task in  self.earnItChildUser.earnItTasks {
        for task in self.tasksForTheMonth {
            if(dateFormatter.string(from: date) == dateFormatter.string(from: task.dueDate)) {
                taskCount = taskCount+1
                selectedDateTasks.append(task)
            }
        }
        if (taskCount == 1 && selectedDateTasks.count == 1) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
            taskSubmitScreen.earnItTask = selectedDateTasks[0]
            self.present(taskSubmitScreen, animated:true, completion:nil)
        }
        else {
            //self.dismiss(animated: false, completion: nil)
            if (selectedDateTasks.count > 1) {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "VCChildTasksList") as! VCChildTasksList
                taskSubmitScreen.tasksForTheDay = selectedDateTasks
                self.present(taskSubmitScreen, animated:true, completion:nil)
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(bounds.height)
            // Do other updates
        }
        self.view.layoutIfNeeded()
    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
////        let dateString = self.dateFormatter1.string(from: date)
////        if self.selectedDates.contains(dateString) {
////            return UIColor.earnItAppPinkColor()
////        }
//        return UIColor.earnItAppPinkColor()
//    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance,  titleDefaultColorFor date: Date) -> UIColor? {
        return UIColor.white
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        //Do some checks and return whatever color you want to.
        return UIColor.white //.earnItAppPinkColor()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
//        let key = self.dateFormatter2.string(from: date)
//        if self.datesWithMultipleEvents.contains(key) {
//            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
//        }
        return [UIColor.white] //[UIColor.earnItAppPinkColor()]
    }
    
    func calendar(_ calendar: FSCalendar!, shouldOutlineEventsForDate date: NSDate!) -> Bool! {
        return true
    }
    
    func setupTasksArrayForChildCalendar() {
        self.tasksForTheMonth.removeAll()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        for task in  self.earnItChildUser.earnItTasks {
            if(task.repeatMode == repeatMode(rawValue: "daily")!) {
                for i in 0 ..< 40 {
                    task.dueDate = task.dueDate.addingTimeInterval(TimeInterval(60*60*24*i))
                    var taskObj = EarnItTask()
                    taskObj = task
                    taskObj.dueDate = taskObj.dueDate.addingTimeInterval(TimeInterval(60*60*24*i))
                    self.tasksForTheMonth.append(taskObj)
                }
            }
            else if(task.repeatMode == repeatMode(rawValue: "weekly")!) {
                for i in 0 ..< 5 {
//                    task.dueDate = task.dueDate.addingTimeInterval(TimeInterval(60*60*24*7*i))
                    var taskObj = EarnItTask()
                    taskObj = task
                    taskObj.dueDate = taskObj.dueDate.addingTimeInterval(TimeInterval(60*60*24*7*i))
                    self.tasksForTheMonth.append(taskObj)
                }
            }
            else if(task.repeatMode == repeatMode(rawValue: "monthly")!) {
                for i in 0 ..< 2 {
//                    task.dueDate = task.dueDate.addingTimeInterval(TimeInterval(60*60*24*31*i))
                    var taskObj = EarnItTask()
                    taskObj = task
                    taskObj.dueDate = taskObj.dueDate.addingTimeInterval(TimeInterval(60*60*24*31*i))
                    self.tasksForTheMonth.append(taskObj)
                }
            }
            else {
                var taskObj = EarnItTask()
                taskObj = task
                self.tasksForTheMonth.append(taskObj)
                print("none")
            }
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentMonth = calendar.month(of: calendar.currentPage)
        print("this is the current Month \(currentMonth)")
//        self.setupTasksArrayForChildCalendar()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
//        dateFormatter.locale = Locale.init(identifier: "fa_IR")
        dateFormatter.locale = Locale(identifier: "en_US")
        var taskCount = Int()
        taskCount = 0
        
//        for task in  self.tasksForTheMonth {
////            print(dateFormatter.string(from: date))
//            print(dateFormatter.string(from: task.dueDate))
//            if (dateFormatter.string(from: task.dueDate) == "2018/03/26") {
//                print("XXX")
//            }
//            if (dateFormatter.string(from: task.dueDate) == "2018/06/20") {
//                print("XXX")
//            }
//            if (dateFormatter.string(from: date) == "2018/06/19") {
//                print("XXX")
//            }
//
//            if(dateFormatter.string(from: date) == dateFormatter.string(from: task.dueDate)) {
//                //                earnItTask.repeatMode.rawValue
//                taskCount = taskCount+1
//            }
//        }
//        return taskCount

        
        for task in  self.earnItChildUser.earnItTasks {
            if(dateFormatter.string(from: date) == dateFormatter.string(from: task.dueDate)) {
//                earnItTask.repeatMode.rawValue
                taskCount = taskCount+1
            }
        }
        return taskCount
    }
}
