//
//  CheckEarnItUserAuthentication.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainSwift
//import RNCryptor

//func encryptMessage(message: String, encryptionKey: String) throws -> String {
//    let messageData = message.data(using: .utf8)!
//    let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
//    return cipherData.base64EncodedString()
//}

 func checkUserAuthentication(email: String!, password: String!, success: @escaping(JSON) -> (), failure: @escaping(NSError) -> ()){
    let loginString = String(format:"%@:%@", email, password)
    let base64LoginString = loginString.base64Encoded()
    
    /*let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString1 = loginData.base64EncodedString()
    if let base64Str = "mah@gmail.com:123456".base64Encoded() {
        if let trs = base64Str.base64Decoded() {
        }
    }*/
    print(String(describing: base64LoginString!))
    let headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Basic \(String(describing: base64LoginString!))"
    ]
//    let param = ["email": email, "password": password] as [String: String]
    print("login url is \(EarnItApp_BASE_URL)/login")
//    Alamofire.request("\(EarnItApp_BASE_URL)/login",method: .post, parameters: param, encoding: JSONEncoding.default , headers: headers)
    Alamofire.request("\(EarnItApp_BASE_URL)/login", method: .get, parameters: nil, encoding: JSONEncoding.default , headers: headers)
        .responseJSON { response in
            switch response.result {
            case .success:
                let  responseJSON = JSON(response.result.value!)
                     print("response.result.value for user login \(response.result.value)")
                     success(responseJSON)
//                UserDefaults.standard.set("\(base64LoginString)", forKey: "user_auth") //setUserAuth
//                UserDefaults.standard.synchronize()
                let keychain = KeychainSwift()
                keychain.set(password, forKey: "password")
                keychain.set("\(String(describing: base64LoginString!))", forKey: "user_auth")
               // print(keychain.get("user_auth")!)
               //  print(keychain.get("password")!)

            case .failure(_):
                print("response.result.error Login--- \(response.result.error)")
                failure(response.result.error as! NSError)
            }
      }
}

func callApiToSendToken(token: String!,success: @escaping(JSON) ->(),failure: @escaping(NSError) -> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    var email = ""
    var password = ""
    
    
    if let emailTemp = keychain.get("email") {
        email = emailTemp
    }
    if let password = keychain.get("password") {
        email = password
    }
    
    
    var basic = ""
    if let basicTemp = keychain.get("user_auth") {
        basic = basicTemp
    }
    
    let headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Basic \(basic)"
    ]
    
    Alamofire.request("\(EarnItApp_BASE_URL)/token",method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        .responseJSON { response in
            
            switch response.result{
                
            case .success:
                
                let responseJSON = JSON(response.result.value!)
                
            case .failure(_):
                
                print("repsone.result.error token sending \(response.result.error)")
                failure(response.result.error as! NSError)
            }
      }
}

extension String {
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
