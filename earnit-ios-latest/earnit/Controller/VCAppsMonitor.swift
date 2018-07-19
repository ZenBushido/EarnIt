//
//  VCAppsMonitor.swift
//  earnit
//
//  Created by Gaurav on 06/4/18.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class VCAppsMonitor : UIViewController,UITextViewDelegate,UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var userImageView: UIImageView!
    var earnItChildUser =  EarnItChildUser()
    var earnItChildUsers = [EarnItChildUser]()
    var actionView = UIView()
    var messageView = MessageView()
    var constX:NSLayoutConstraint?
    var constY:NSLayoutConstraint?
    var isActiveUserChild = false

    @IBOutlet var tvAppsUsage: UITableView!
    var earnItChildGoalList = [EarnItChildGoal]()
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnAdjust: UIButton!
    @IBOutlet var lblSubtitle: UILabel!

    @IBOutlet var segControl: UISegmentedControl!

    //MARK: View Cycle
    
    override func viewDidLoad() {
        if (EarnItAccount.currentUser.firstName != nil) {
         self.lblTitle.text = "Hi" + " " + EarnItAccount.currentUser.firstName
        }
        else {
         self.lblTitle.text = "Hi" + " " + self.earnItChildUser.firstName!
        }
        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGesture)
//        self.btnAdjust.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.getGoalListForCurrentUser), name: NSNotification.Name(rawValue: "getGoalList_UserData"), object: nil)
//        self.messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?[0] as? MessageView)!
//        self.messageView.center = CGPoint(x: self.view.center.x,y :self.view.center.y-80)
//        self.messageView.messageText.delegate = self
        
//        let userAvatarUrlString = self.earnItChildUser.childUserImageUrl
//        self.userImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX + self.earnItChildUser.childUserImageUrl!)
//        self.messageView.messageToLabel.text = "Message to  \(self.earnItChildUser.firstName!):"
        self.changeSubtileTitle()
        self.segControl.tintColor = UIColor.earnItAppPinkColor() //UIColor.white
        self.segControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        
        self.tvAppsUsage.allowsSelection = true
        self.tvAppsUsage.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tvAppsUsage.tableFooterView = UIView()
        self.tvAppsUsage.reloadData()
        self.getGoalListForCurrentUser()
    }
    
    //MARK: Segment Control
    
    @IBAction func monitorOptionSegmentChange(sender: UISegmentedControl) {
        self.changeSubtileTitle()
        return
        let sortedViews = sender.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        for (index, view) in sortedViews.enumerated() {
            if index == sender.selectedSegmentIndex {
                view.tintColor = UIColor.blue
            } else {
                view.tintColor = UIColor.lightGray
            }
        }
    }
    
    func changeSubtileTitle() {
        let strSelectedSegment = segControl.titleForSegment(at: segControl.selectedSegmentIndex)
        self.lblSubtitle.text = strSelectedSegment! + " Usage"
    }
    
    //MARK: Get Goal List

    func getGoalListForCurrentUser(){
        self.earnItChildGoalList.removeAll()
        getGoalsForChild(childId : self.earnItChildUser.childUserId,success: {
            (earnItGoalList) ->() in
            for earnItGoal in earnItGoalList{
                print(earnItGoal.cash!)
                self.earnItChildGoalList.append(earnItGoal)
                self.earnItChildUser.earnItGoal = earnItGoal
            }
            self.earnItChildGoalList = self.earnItChildGoalList.reversed()
            self.tvAppsUsage.reloadData()

        })
        { (error) -> () in
            self.view.makeToast("Apps usage failed")
        }
    }
    
    //MARK: Action Methods
    
    @IBAction func adjustButtonClicked(_ sender: Any) {
        if self.isActiveUserChild == true {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
            self.present(childDashBoard, animated: true, completion: nil)
        }
        else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let adjustBalance = storyBoard.instantiateViewController(withIdentifier: "VCAdjustBalance") as! VCAdjustBalance
            adjustBalance.earnItChildUsers = self.earnItChildUsers
            adjustBalance.earnItChildUser = self.earnItChildUser
            adjustBalance.earnItChildGoalList = self.earnItChildGoalList
            self.present(adjustBalance, animated: true, completion: nil)
        }
    }
    
    @IBAction func homeButtonClicked(_ sender: Any) {
        return
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
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func userImageViewGotTapped(_ sender: UITapGestureRecognizer) {
        
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
    
    //MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.earnItChildGoalList.count
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let childCell = self.tvAppsUsage.dequeueReusableCell(withIdentifier: "ChildCell", for: indexPath as IndexPath) as! ChildCell
        /*let earnItGoal = self.earnItChildGoalList[indexPath.row]
        
        if earnItGoal.name == "" || earnItGoal.name == nil {
            childCell.childName.text = "No goal assigned yet!!"
            childCell.lblPercentValue.text = ""
        }
        else {
            childCell.childName.text = "\(earnItGoal.name!):"
//            childCell.lblPercentValue.text = "$\(earnItGoal.tally!) of $\(earnItGoal.ammount!)  / \(earnItGoal.tallyPercent!)%"
            var amountValue:Int = 0
            for objAdjustment in earnItGoal.arrAdjustments {
                amountValue = (objAdjustment["amount"]! as? Int)! + amountValue
            }
            childCell.lblPercentValue.text = "$\(earnItGoal.ammount! + amountValue) of $\(earnItGoal.ammount!)" // / \(earnItGoal.tallyPercent!)%"
        }*/
        childCell.childName.isUserInteractionEnabled = false
        childCell.lblPercentValue.isUserInteractionEnabled = false
        if (indexPath.row == 0) {
            childCell.childName.text = "Today"
            childCell.lblPercentValue.text = "12 hour, 38 mins"
        }
        else {
            childCell.childName.text = "Yesterday"
            childCell.lblPercentValue.text = "12 hour, 38 mins"
        }
        let viewCornerRadius : CGFloat = 5
        let borderLayer : CAShapeLayer = CAShapeLayer()
        let progressLayer : CAShapeLayer = CAShapeLayer()

        childCell.viewProg.layer.cornerRadius = viewCornerRadius
        let bezierPath = UIBezierPath(roundedRect: childCell.viewProg.bounds, cornerRadius: viewCornerRadius)
        bezierPath.close()
        borderLayer.path = bezierPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeEnd = 0
        childCell.viewProg.layer.addSublayer(borderLayer)

        //Make sure the value that you want in the function `rectProgress` that is going to define
        //the width of your progress bar must be in the range of
        // 0 <--> viewProg.bounds.width - 10 , reason why to keep the layer inside the view with some border left spare.
        //if you are receiving your progress values in 0.00 -- 1.00 range , just multiply your progress values to viewProg.bounds.width - 10 and send them as *incremented:* parameter in this func
//        if incremented <= viewProg.bounds.width - 10{
            progressLayer.removeFromSuperlayer()
//        let rect = CGRect(x: 5, y: 5, width: (0.5*(childCell.viewProg.bounds.width - 10)), height: childCell.viewProg.bounds.height - 10) // CGFloat, Double, Int
            let bezierPathProg = UIBezierPath(roundedRect: CGRect(x: 5, y: 5, width: (0.69*(childCell.viewProg.bounds.width - 10)), height: childCell.viewProg.bounds.height - 10) , cornerRadius: viewCornerRadius)
            bezierPathProg.close()
            progressLayer.path = bezierPathProg.cgPath
        progressLayer.fillColor = UIColor.earnItAppProgressBarColor().cgColor //UIColor.white.cgColor
            borderLayer.addSublayer(progressLayer)
//        }

        return childCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("yes selected....")
    }
    
}
