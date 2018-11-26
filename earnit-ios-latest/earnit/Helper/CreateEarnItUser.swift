//
//  CreateEarnItUser.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainSwift

enum repeatMode : String {
    case None = "none"
    case Daily = "daily"
    case Weekly = "weekly"
    case Monthly = "monthly"
}

func callUpdateProfileApiForParentt(firstName: String, lastName: String, phoneNumber: String,updatedPassword: String,imageUrl: String,fcmKey: String?,success: @escaping(Bool)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    guard  let _ = keychain.get("user_auth") else  {
        print(" /n Unable to fetch user auth from keychain \n")
        return
    }
    let email : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String

    print("new password to sendt \(password)")
    var headers : HTTPHeaders = [:]
    
    if let authorizationHeader = Request.authorizationHeader(user: email, password: password){
        
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
//    
//    var token : String!
//    
//    if let fcmToken = fcmKey {
//        
//        token = fcmToken
//        
//    }else {
//        
//        token = ""
//    }
    
    let params = [
        "id": EarnItAccount.currentUser.id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "password": updatedPassword,
        "phone": phoneNumber,
        "avatar": imageUrl,
        "createDate": EarnItAccount.currentUser.createDate,
        "account": ["id": EarnItAccount.currentUser.accountId],
        "fcmToken": fcmKey
       
    ] as [String : Any]
    
    print("param before parent update \(params)")
    Alamofire.request("\(EarnItApp_BASE_URL)/parent",method: .put,parameters: params, encoding: JSONEncoding.default,headers: headers).responseJSON{ response in
        switch(response.result){
        case .success:
            let responseJSON = JSON(response.result.value)
            EarnItAccount.currentUser.setAttribute(json: responseJSON)
            keychain.set(responseJSON["email"].stringValue, forKey: "email")
//            keychain.set(responseJSON["password"].stringValue, forKey: "password")
//            keychain.set(updatedPassword, forKey: "password")
            print("response.result.value EarnIt Parent User,\(responseJSON)")
            success(true)
        case .failure(_):
            print(response.result.error ?? "Error Got")
        }
    }
}

func callUpdateProfileImageApiForParent(firstName: String, lastName: String, phoneNumber: String,updatedPassword: String,userAvatar: String,success: @escaping(Bool)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let email : String = keychain.get("email")!
    let password : String = keychain.get("password") as! String
    
    var headers : HTTPHeaders = [:]
    
    if let authorizationHeader = Request.authorizationHeader(user: email, password: password){
        
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    
    let params = [
        "id": EarnItAccount.currentUser.id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "password": updatedPassword,
        "phone": phoneNumber,
        "avatar": userAvatar,
        "createDate": EarnItAccount.currentUser.createDate,
        "account": ["id": EarnItAccount.currentUser.accountId]
        
        ] as [String : Any]
    
    print("param for profile image before update \(params)")
    Alamofire.request("\(EarnItApp_BASE_URL)/parent",method: .put,parameters: params, encoding: JSONEncoding.default,headers: headers).responseJSON{ response in
        
        switch(response.result){
            
        case .success:
            
            let responseJSON = JSON(response.result.value)
            EarnItAccount.currentUser.setAttribute(json: responseJSON)
            print("response.result.value EarnIt Parent User,\(responseJSON)")
            success(true)
        case .failure(_):
            
            print(response.result.error)
            
        }
    }
}

func callSignUpApiForParent(email: String, password: String,success: @escaping(JSON,String)-> (),failure: @escaping(Bool)-> ()){
    
    let params = [
        "email": email,
        "password": password
    ]
    Alamofire.request("\(EarnItApp_BASE_URL)/signup/parent",method: .post,parameters: params, encoding: JSONEncoding.default,headers: nil).responseJSON{ response in
        
        switch(response.result){
        case .success:
            let loginString = String(format:"%@:%@", email, password)
            let base64LoginString = loginString.base64Encoded()
            let keychain = KeychainSwift()
            keychain.set("\(String(describing: base64LoginString!))", forKey: "user_auth")
            print(keychain.get("user_auth")!)
            
            let responseJSON = JSON(response.result.value)
            print("response.result.value EarnIt Parent User,\(responseJSON)")
            success(responseJSON,responseJSON["code"].stringValue)
        case .failure(_):
            
            print(response.result.error)
        }
    }
}


func callSignUpApiForChild(firstName: String,email: String, password: String,childAvatar: String,phoneNumber: String?, success: @escaping(EarnItChildUser,String)-> (),failure: @escaping(Bool)-> ()){
    
    print("phone number is \(phoneNumber!)")
    var params = [String:Any]()
    
    if phoneNumber != nil || phoneNumber != ""{
        
        params = [
            
            "account": ["id": EarnItAccount.currentUser.accountId],
            "email": email,
            "firstName": firstName,
            "password": password,
            "avatar" : childAvatar,
            "phone" : phoneNumber!
            
            ] as [String : Any]
        
    }else {
        
        params = [
            
            "account": ["id": EarnItAccount.currentUser.accountId],
            "email": email,
            "firstName": firstName,
            "password": password,
            "avatar" : childAvatar
            
            ] as [String : Any]
    }
    
    print("params before add child \(params)")
    Alamofire.request("\(EarnItApp_BASE_URL)/signup/child",method: .post,parameters: params, encoding: JSONEncoding.default,headers: nil).responseJSON{ response in
        switch(response.result){
        case .success:
            
            let responseJSON = JSON(response.result.value)
            print("response.result.value EarnIt Child User SignUp,\(responseJSON)")
            
            let earnItChild = EarnItChildUser()
            earnItChild.setAttribute(json: responseJSON)
            success(earnItChild,responseJSON["code"].stringValue)
        case .failure(_):
            
            print(response.result.error)
        }
    }
}

//Delete Goal Call

func callForDeleteGoal(goal_id: Int, success: @escaping(String)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }    
    Alamofire.request("\(EarnItApp_BASE_URL)/goals/\(goal_id)", method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
        
        switch(response.result){
        case .success:
            
            let responseJSON = JSON(response.result.value)
            print("response.result.value EarnIt Child User SignUp,\(responseJSON)")
            
            success(responseJSON["code"].stringValue)
        case .failure(_):
            
            print(response.result.error)
        }
    }
}

//Delete Child Call

func callForDeleteChild(children_id: Int, success: @escaping(String)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    Alamofire.request("\(EarnItApp_BASE_URL)/childrens/\(children_id)", method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
        
        switch(response.result){
        case .success:
            
            let responseJSON = JSON(response.result.value)
            print("response.result.value EarnIt Child User SignUp,\(responseJSON)")
            
            success(responseJSON["code"].stringValue)
        case .failure(_):
            
            print(response.result.error)
        }
    }
}

func callForgotPasswordApiForUser(email: String!, success: @escaping(JSON) -> (), failure: @escaping(NSError) -> ()){
    let keychain = KeychainSwift()
    var headers : HTTPHeaders = [:]
    /*guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String

    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        headers = [
            "Accept": "application/json",
            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json"
        ]
    }*/
    print("user email is \(email!)")
    var params = [String:Any]()
    params = [
        "email": email
        ] as [String : Any]
    //print("\(EarnItApp_BASE_URL)/passwordReminder")
    Alamofire.request("\(EarnItApp_BASE_URL)/passwordReminder",method: .post,parameters: params, encoding: JSONEncoding.default , headers: nil)//headers
        .responseJSON { response in
            switch response.result {
            case .success:
                let  responseJSON = JSON(response.result.value!)
                print("response.result.value for forgot password \(String(describing: response.result.value))")
                success(responseJSON)
                
            case .failure(_):
                print("response.result.error forgot password--- \(String(describing: response.result.error))")
                failure(response.result.error as! NSError)
            }
    }
}

func callAdjustBalanceApiForUser(amount: Int, strReason: String!, strOperation: String!, idGoal: Int, success: @escaping(JSON) -> (), failure: @escaping(NSError) -> ()){
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let userEmail : String = keychain.get("email")!
    let password : String = keychain.get("password")! //as! String
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: userEmail, password: password){
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    var params = [String:Any]()
    params = [
        "amount": "\(strOperation!)\(amount)",
        "reason": "\(strReason!)",
        "goal": ["id": idGoal]
        ] as [String : Any]
    print(params)
    
    //print("\(EarnItApp_BASE_URL)/passwordReminder")
    Alamofire.request("\(EarnItApp_BASE_URL)/adjustments",method: .post,parameters: params, encoding: JSONEncoding.default , headers: headers)
        .responseJSON { response in
            switch response.result {
            case .success:
                let  responseJSON = JSON(response.result.value!)
                print("response.result.value for forgot password \(String(describing: response.result.value))")
                success(responseJSON)
                
            case .failure(_):
                print("response.result.error forgot password--- \(String(describing: response.result.error))")
                failure(response.result.error as! NSError)
            }
    }
}

func callUpdateApiForChild(firstName: String,childEmail: String, childPassword: String,childAvatar: String,createDate: Int,childUserId: Int,childuserAccountId: Int,phoneNumber: String?,fcmKey: String?,message: String?, success: @escaping(Bool)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let email : String = keychain.get("email")!
    let password : String = keychain.get("password") as! String
    
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: email, password: password){
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    var params = [String:Any]()
//    
//    var token : String!
//    
//    if let fcmToken = fcmKey {
//        
//        token = fcmToken
//        
//    }else {
//        
//        token = ""
//    }
    
    print("phone number befor update \(phoneNumber!)")
    if phoneNumber != nil || phoneNumber != ""{
        
        params = [
            "account": ["id": childuserAccountId],
            "id" : childUserId,
            "email": childEmail,
            "firstName": firstName,
            "password": childPassword,
            "createDate": createDate,
            "avatar" : childAvatar,
            "phone" : phoneNumber!,
            "fcmToken" : fcmKey,
            "message": message,
            
            ] as [String : Any]
        
    }else {
        
        params = [
            "account": ["id":childuserAccountId],
            "id" : childUserId,
            "email": email,
            "firstName": firstName,
            "password": password,
            "createDate": createDate,
            "avatar" : childAvatar,
            "fcmToken" : fcmKey,
            "message": message,
            
            ] as [String : Any]
    }

    print("params before update \(params)")
    Alamofire.request("\(EarnItApp_BASE_URL)/children",method: .put,parameters: params, encoding: JSONEncoding.default,headers: headers).responseJSON{ response in
        switch(response.result){
            
        case .success:
            
            let responseJSON = JSON(response.result.value)
            print("response.result.value EarnIt Child User update,\(responseJSON)")
            success(true)
        case .failure(_):
            
            print(response.result.error)
        }
    }
}

func createEarnItAppChildUser(success: @escaping([EarnItChildUser])-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
   
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    
    var headers : HTTPHeaders = [:]
    
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    print("header value \(headers)")
    print("API URL :- \(EarnItApp_BASE_URL)")
    
    Alamofire.request("\(EarnItApp_BASE_URL)/childrens/\(EarnItAccount.currentUser.accountId)",method: .get, encoding: JSONEncoding.default,headers: headers).responseJSON{ response in
        
        switch(response.result){
            
        case .success:
            
            let responseJSON = JSON(response.result.value)
            var earnItChildUsers = [EarnItChildUser]()
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.ReferenceType.local
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            for (_,childUserObject) in responseJSON {
                
                let earnItChildUser = EarnItChildUser()
                print("START earnItChild  creation \(childUserObject["firstName"].stringValue)")
                print(Date().millisecondsSince1970)
                earnItChildUser.setAttribute(json: childUserObject)
                print("END earnItChild creation \(childUserObject["name"].stringValue)")
                print(Date().millisecondsSince1970)
                earnItChildUsers.append(earnItChildUser)
            }

            print("EarnItChildUser for parent in response\(response.result.value)")
            success(earnItChildUsers)
            print("response.result.value EarnIt Child User,\(responseJSON)")
            
        case .failure(_):
            
            print(response.result.error)
        }
    }
}

func addTaskForChild(childId: Int, earnItTask: EarnItTask,earnItSelectedGoal: EarnItChildGoal,success: @escaping(Bool)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        
        headers = [
            "Accept": "application/json",
            //            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    var param = [String: Any]()
    var status = ""
    var str_id = ""
    var taskName = ""
    var allowance = 0.00
    var updateDateTimeStamp : Int64 = 0
    var dueDateTimeStamp : Int64 = 0
    var createdDateTimeStamp : Int64 = 0
    var isPictureRequired : Int = 0
    
    if let isPictureRequiredTemp = earnItTask.isPictureRequired {
        isPictureRequired = isPictureRequiredTemp
    }
    if let statusTemp = earnItTask.status {
        status = statusTemp
    }
    if let idTemp = earnItSelectedGoal.id {
        str_id = idTemp.description
    }
    
    if let taskNameTemp = earnItTask.taskName {
        taskName = taskNameTemp
    }
    if let allowanceTemp = earnItTask.allowance {
        allowance = allowanceTemp
    }
    if let dueDateTimeStampTemp = earnItTask.dueDateTimeStamp {
        dueDateTimeStamp = dueDateTimeStampTemp
    }
    if let updateDateTimeStampTemp = earnItTask.updateDateTimeStamp {
        updateDateTimeStamp = updateDateTimeStampTemp
    }
    if let createdDateTimeStampTemp = earnItTask.createdDateTimeStamp {
        createdDateTimeStamp = createdDateTimeStampTemp
    }
    

    if earnItTask.repeatMode.rawValue == "none"{
        
        print("selected goal for Api \(earnItSelectedGoal.id)")
        if earnItSelectedGoal.name != "None"{
            param = [
                
                "children": ["id": childId],
                "allowance": allowance,
                "createDate": createdDateTimeStamp,
                "dueDate": dueDateTimeStamp,
                "name": taskName,
                "pictureRequired": isPictureRequired,
                "status": status,
                "updateDate": updateDateTimeStamp,
                "taskComments": [],
                "description" : earnItTask.taskDescription!,
                "goal" : ["id": earnItSelectedGoal.id!]
            ]
            
        }else {
            
            param = [
                "children": ["id": childId],
                "allowance": allowance,
                "createDate": createdDateTimeStamp,
                "dueDate": dueDateTimeStamp,
                "name": taskName,
                "pictureRequired": isPictureRequired,
                "status": status,
                "updateDate": updateDateTimeStamp,
                "taskComments": [],
                "description" : earnItTask.taskDescription!
            ]
        }
        
    }
    else if earnItTask.repeatMode.rawValue == "daily"{
        
        
        param = [
            
            "children": ["id": childId],
            "allowance": allowance,
            "createDate":createdDateTimeStamp,
            "dueDate": dueDateTimeStamp,
            "name": taskName,
            "pictureRequired": isPictureRequired,
            "status": status,
            "updateDate": updateDateTimeStamp,
            "taskComments": [],
            "description" : earnItTask.taskDescription!,
            "goal" : ["id": str_id],
            "repititionSchedule":["startTime":"10:00", "endTime" : "11:00","repeated": "daily"]
            
            
        ]
        
    }
    else if earnItTask.repeatMode.rawValue == "weekly"{
        param = [
            
            "children": ["id": childId],
            "allowance": allowance,
            "createDate":createdDateTimeStamp,
            "dueDate": dueDateTimeStamp,
            "name": taskName,
            "pictureRequired": isPictureRequired,
            "status": status,
            "updateDate": updateDateTimeStamp,
            "taskComments": [],
            "description" : earnItTask.taskDescription!,
            "goal" : ["id": str_id],
            "repititionSchedule":["startTime":"00:00", "endTime" : "23:59","repeated": "weekly","specificDays":earnItTask.specificDays]
            
            
        ]
        
    }
    else if earnItTask.repeatMode.rawValue == "monthly"{
        param = [
            
            "children": ["id": childId],
            "allowance": allowance,
            "createDate": createdDateTimeStamp,
            "dueDate": dueDateTimeStamp,
            "name": taskName,
            "pictureRequired": isPictureRequired,
            "status": status,
            "updateDate": updateDateTimeStamp,
            "taskComments": [],
            "description" : earnItTask.taskDescription!,
            "goal" : ["id": str_id],
            "repititionSchedule":["startTime":"10:30", "endTime" : "11:45","repeated": "monthly","specificDays":earnItTask.specificDays]
        ]
        
    }
    else {
        
        param = [
            "children": ["id": childId],
            "allowance": allowance,
            "createDate": createdDateTimeStamp,
            "dueDate": dueDateTimeStamp,
            "name": taskName,
            "pictureRequired": isPictureRequired,
            "status": status,
            "updateDate": updateDateTimeStamp,
            "taskComments": [],
            "description" : earnItTask.taskDescription!
        ]
    }
    if earnItTask.repeatMode == .Weekly {
        
    }
    else if earnItTask.repeatMode == .Monthly {
        
    }
    else if  earnItTask.repeatMode != .None {
        let repeatModeDic = ["repeat" : earnItTask.repeatMode.rawValue]
        param.updateValue(repeatModeDic, forKey: "repititionSchedule")
    }
    print("params before add task \(param)")
    Alamofire.request("\(EarnItApp_BASE_URL)/tasks",method: .post,parameters: param, encoding: JSONEncoding.default,  headers: headers).responseJSON{ response in
        switch(response.result){
        case .success:
            
            success(true)
            print("response.result.value  addTaskForChild,\(response.result.value)")
            
        case .failure(_):
            
            print(response.result.error)
        }
    }
}

func getGoalsForChild(childId : Int,success: @escaping([EarnItChildGoal])-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    Alamofire.request("\(EarnItApp_BASE_URL)/goals/\(childId)",method: .get,parameters: nil, encoding: JSONEncoding.default,  headers: headers).responseJSON{ response in
        switch(response.result){
        case .success:
            print("response.result.value  getGoals,\(String(describing: response.result.value))")
            let responseJSON = JSON(response.result.value)
            var earnItChildGoalList = [EarnItChildGoal]()
            for (_,value) in responseJSON {
                let earnItGoal = EarnItChildGoal()
                print("value \(value["name"])")
                earnItGoal.setAttribute(json: value)
                earnItChildGoalList.append(earnItGoal)
            }
            success(earnItChildGoalList)
        case .failure(_):
            print(response.result.error)
        }
    }
}

func getAllTasksForChild(childId : Int,success: @escaping([(EarnItTask)])-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    Alamofire.request("\(EarnItApp_BASE_URL)/tasks/\(childId)",method: .get,parameters: nil, encoding: JSONEncoding.default,  headers: headers).responseJSON{ response in
        switch(response.result){
        case .success:
            print("response.result.value  getGoals,\(response.result.value)")
            let responseJSON = JSON(response.result.value)
            
            var earnItChildTaskList = [EarnItTask]()
            
            for (_,value) in responseJSON {
                
                let earnItTask = (EarnItTask)()
                print("value \(value["name"])")
                earnItTask.setAttribute(json: value)
                earnItChildTaskList.append(earnItTask)
            }
            success(earnItChildTaskList)
            
        case .failure(_):
            print(response.result.error)
        }
    }
}


func addGoalForChild(childId: Int, amount: Int,createdDate: Int64,goalName: String,success: @escaping(Bool)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    var param = [String: Any]()

    param = [
    
     "children": ["id": childId ],
      "amount": amount,
      "createDate": createdDate,
      "name": goalName
    ]
    Alamofire.request("\(EarnItApp_BASE_URL)/goals",method: .post,parameters: param, encoding: JSONEncoding.default,  headers: headers).responseJSON{ response in
        switch(response.result){
        case .success:
            
            success(true)
            print("response.result.value  added Goal,\(response.result.value)")
            
        case .failure(_):
            
            print(response.result.error)
        }
    }
}

func editGoalForChild(id:Int, childId: Int, amount: Int,createdDate: Int64,goalName: String,success: @escaping(Bool)-> (),failure: @escaping(Bool)-> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    var headers : HTTPHeaders = [:]
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        
        headers = [
            "Accept": "application/json",
//            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json",
            "Authorization": "Basic \(keychain.get("user_auth")!)"
        ]
    }
    var param = [String: Any]()
    
    param = [
        "id" : id,
        "children": ["id": childId ],
        "amount": amount,
        "createDate": createdDate,
        "name": goalName
    ]
    Alamofire.request("\(EarnItApp_BASE_URL)/goals",method: .put,parameters: param, encoding: JSONEncoding.default,  headers: headers).responseJSON{ response in
        switch(response.result){
        case .success:
            
            success(true)
            print("response.result.value  Updated Goal,\(response.result.value)")
            
        case .failure(_):
            
            print(response.result.error)
        }
    }
}



