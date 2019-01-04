//
//  OptionViewController.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/8/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import KeychainSwift

enum OptionMenu: Int{
    case home  = 0
    case account
  //  case settings
    case logout
    case version
    
}

protocol OptionMenuProtocol : class {
    
    func changeViewController(_ option: OptionMenu)
}

class OptionViewController: UIViewController, OptionMenuProtocol {
 @IBOutlet var versionBtn: UIButton!
   @IBOutlet var tableView: UITableView!
   var options = ["Home","Account","Logout"]
   var imageViewHeader: ImageViewHeader!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
  
    func changeViewController(_ option: OptionMenu) {
        switch option {
        case .home:
            print("home")
        case .account:
            print("account")
//        case .settings:
//            print("settings")
        case .logout:
            print("logtout")
        case .version:
            print("version")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let selected_color = UIColor(red: 115.0/255.0, green: 244.0/255.0, blue: 64.0/255.0, alpha: 1)
        
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            versionBtn.setTitle("Version \(version)", for: .normal)
             versionBtn.setTitle("Version \(version)", for: .selected)

            
        }
        
        self.imageViewHeader = ImageViewHeader.loadNib()
         self.imageViewHeader.userProfileImageView.image = UIImage(named: "user-pic")
       
       // self.imageViewHeader.userProfileImageView.image = EarnItImage.defaultUserImage()
        self.imageViewHeader.userName.text = EarnItAccount.currentUser.firstName
        self.imageViewHeader.email.text = EarnItAccount.currentUser.email
        
      //  imageViewHeader.userProfileImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX +  EarnItAccount.currentUser.avatar!)
        
        if  let imgurl = EarnItAccount.currentUser.avatar{
            if imgurl.count > 0 {
                imageViewHeader.userProfileImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX +  imgurl)
            }
            else {
                imageViewHeader.userProfileImageView.image = UIImage(named: "user-pic")
            }
        }
        else {
            
            
            imageViewHeader.userProfileImageView.image = UIImage(named: "user-pic")
            
        }
        
    
        imageViewHeader.userProfileImageView.contentMode = .scaleAspectFill

        self.tableView.registerCellClass(OptionCell.self)
    
        self.tableView.isScrollEnabled = false
    
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.imageViewHeader)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       // self.imageViewHeader.userProfileImageView.image = EarnItImage.defaultUserImage()
        DispatchQueue.main.async {
           // self.imageViewHeader.userProfileImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX + EarnItAccount.currentUser.avatar!)
            if  let imgurl = EarnItAccount.currentUser.avatar{
                if imgurl.count > 0 {
                   self.imageViewHeader.userProfileImageView.loadImageUsingCache(withUrl: EarnItApp_Image_BASE_URL_PREFIX + imgurl)
                }
                else {
                    self.imageViewHeader.userProfileImageView.image = UIImage(named: "user-pic")
                }
            }
            else {
                
                
                  self.imageViewHeader.userProfileImageView.image = UIImage(named: "user-pic")
                
            }
            
            
        }
        self.imageViewHeader.userName.text = EarnItAccount.currentUser.firstName
        self.imageViewHeader.email.text = EarnItAccount.currentUser.email
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("self.imageViewHeader.frame height \(self.imageViewHeader.frame.height)")
        //self.imageViewHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.imageViewHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 175)
        self.view.layoutIfNeeded()
    }
}


extension OptionViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let option = OptionMenu(rawValue: indexPath.row){
            self.checkForOptions(option: option)
        }
    }
    
    
    func checkForOptions(option: OptionMenu){
        
            switch option {
            case .home:
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

                let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
                
                let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                
                let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
                
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                slideMenuController.delegate = parentLandingPage
                
                self.present(slideMenuController, animated:false, completion:nil)
                
            case .account:
                
                self.closeLeft()
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let parentProfile = storyBoard.instantiateViewController(withIdentifier: "ParentProfilePage") as! ParentProfilePage
                 self.present(parentProfile, animated:false, completion:nil)
                
//            case .settings:
//                
//                 self.view.makeToast("Settings")
//                let alert = showAlertWithOption(title: "Settings clicked ", message: "")
//                
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)

            case .logout:
                let keychain = KeychainSwift()
                keychain.delete("isActiveUser")
                keychain.delete("email")
                keychain.delete("password")
                keychain.delete("isProfileUpdated")
                UIApplication.shared.unregisterForRemoteNotifications()

                //keychain.delete("token")
                EarnItAccount.resetCurrentUser()
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
                self.present(loginController, animated: true, completion: nil)
                
            case .version:
                print("version")
            }
    }
}

extension OptionViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let menu = OptionMenu(rawValue: indexPath.row){
            
            switch menu {
                
             //   case .home, .account, .settings, .logout, .version :
                     case .home, .account,  .logout, .version :
                    
                    let cell = OptionCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: OptionCell.identifier)
                   cell.imageView?.image = self.faImage(menuItem: OptionMenu(rawValue: indexPath.row)!)
                    switch OptionMenu(rawValue: indexPath.row) {
                    case .home?:
                         cell.imageView?.image = UIImage(named: "home")
                    case .account?:
                       cell.imageView?.image = UIImage(named: "account")
                    case .logout?:
                   cell.imageView?.image = UIImage(named: "logout")
                    case .version?:
                        print("")
                       //cell.imageView?.image = UIImage(named: "")
                    case .none:
                        print("")
                    }
                    
                    
                    
                    
                    cell.setData(options[indexPath.row])
                      cell.layer.addBorder(edge: .top, color: UIColor.white, thickness: 0.5)
                    if indexPath.row == 3{
                        
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            cell.setData("        Version \(version)")
                          
                        }
                        
                    }
                    cell.backgroundColor = self.menuBackColor(menuItem: OptionMenu(rawValue: indexPath.row)!)
                    cell.textLabel?.textColor = self.menuTextColor(menuItem: OptionMenu(rawValue: indexPath.row)!)
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor(red: 92.0/255.0, green: 125.0/255.0, blue: 246.0/255.0, alpha: 1)
                    
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    /*
    //HIGHLIGHT ON CLICK TABLE CELL
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //cell?.contentView.backgroundColor = UIColor.EarnItAppBackgroundColor()
        cell?.textLabel?.textColor = UIColor.EarnItAppBackgroundColor()
        cell?.imageView?.maskWith(color: UIColor.EarnItAppBackgroundColor())
        cell?.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //cell?.contentView.backgroundColor = UIColor.white
        cell?.textLabel?.textColor = UIColor.white
        cell?.imageView?.maskWith(color: UIColor.white)
        cell?.backgroundColor = UIColor.EarnItAppBackgroundColor()
    }
    
    */
    
    
    func faImage(menuItem: OptionMenu) -> UIImage {
        switch menuItem {
        case .home:
            return EarnItImage.setHome()
        case .account:
            return EarnItImage.setAccount()
        case .logout:
            return EarnItImage.setLogout()
//        case .settings:
//            return EarnItImage.setSetting()
        case .version:
            return EarnItImage.setVersion()
        }
    }
    func menuBackColor(menuItem: OptionMenu) -> UIColor {
        switch menuItem {
        case .home:
            return UIColor.white
     //   case .account, .logout , .settings, .version:

        case .account, .logout , .version:
            return UIColor.EarnItAppBackgroundColor()
        }
    }
    func menuTextColor(menuItem: OptionMenu) -> UIColor {
        switch menuItem {
        case .home:
              return UIColor.white
             //return UIColor.EarnItAppBackgroundColor()
     //   case .account, .logout , .settings, .version:

        case .account, .logout , .version:
            return UIColor.white
        }
    }
}

