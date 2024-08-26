////
////  AuthClient.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 4.04.24.
////
//
//import Foundation
//import AWSCognitoIdentityProvider
//
//class AuthClient: NSObject, ObservableObject {
//    static let shared: AuthClient = AuthClient()
//    var pool: AWSCognitoIdentityUserPool!
//    var userJustLoggedIn = false
//    
//    override init() {
//        super.init()
//        pool = AWSCognitoIdentityUserPool(forKey: "togeda-main")
//    }
//    
//    func singUp(email username: String, password: String, completion: @escaping (Bool, String?) -> Void){
//        pool?.signUp(username, password: password, userAttributes: nil, validationData: nil).continueWith(block: { (task) -> Any? in
//            if let error = task.error as NSError? {
//                // Extracting the message from userInfo
//                if let errorMessage = error.userInfo["message"] as? String {
//                    print("Error: \(errorMessage)")
//                    completion(false, errorMessage)
//                } else {
//                    print("Error", error)
//                }
//            } else {
//                print("Code Delivery Details", task.result?.codeDeliveryDetails ?? "")
//                completion(true, nil)
//            }
//            
//            return nil
//        })
//        
//        
//    }
//    
//    func confirmSignUp(email username: String, code: String, completion: @escaping (Bool, String?) -> Void){
//        pool?.getUser(username).confirmSignUp(code).continueWith{ (task) -> Any? in
//            if let error = task.error as NSError? {
//                // Extracting the message from userInfo
//                if let errorMessage = error.userInfo["message"] as? String {
//                    print("Error: \(errorMessage)")
//                    completion(false, errorMessage)
//                } else {
//                    print("Error", error)
//                }
//            } else {
//                print(task.result ?? "NO result")
//                completion(true, nil)
//            }
//            
//            return nil
//        }
//    }
//    
//    func resendConfirmationCode(email username: String, completion: @escaping (Bool, String?) -> Void){
//        pool?.getUser(username).resendConfirmationCode().continueWith{ (task) -> Any? in
//            if let error = task.error as NSError? {
//                // Extracting the message from userInfo
//                if let errorMessage = error.userInfo["message"] as? String {
//                    print("Error: \(errorMessage)")
//                    completion(false, errorMessage)
//                } else {
//                    print("Error", error)
//                }
//            } else {
//                print("Code Delivery Details", task.result?.codeDeliveryDetails ?? "")
//                completion(true, nil)
//            }
//            
//            return nil
//        }
//    }
//    
//    func login(email username: String, password: String, completion: @escaping (Bool, Bool, String?) -> Void){
//        pool?.currentUser()?.getSession(username, password: password, validationData: nil).continueWith(block: { (task) -> Any? in
//            if let error = task.error as NSError? {
//                // Extracting the message from userInfo
//                if let errorMessage = error.userInfo["message"] as? String {
//                    print("Error: \(errorMessage)")
//                    
//                    if let errorType = error.userInfo["__type"] as? String, errorType == "UserNotConfirmedException" {
//                        //                              self.authenticationState = .confirmEmail
//                        completion(false, true, errorMessage)
//                    }
//                    
//                    completion(false, false, errorMessage)
//                } else {
//                    print("Error", error)
//                }
//            } else {
//                print("Logged in succesfully!")
//                completion(true, false, nil)
//                self.userJustLoggedIn = true
//            }
//            
//            return nil
//        })
//    }
//    
//    func loginOut(){
//        Task{
//            try await APIClient.shared.removeDiviceToken()
//        }
//        pool?.currentUser()?.signOut()
//    }
//    
//    func clearSession(){
//        pool?.currentUser()?.clearSession()
//        //        self.checkAuthStatus()
//    }
//    
//    func forgotPassword(email username: String, completion: @escaping (Bool, String?) -> Void){
//        pool?.getUser(username).forgotPassword().continueWith{ (response) -> Any? in
//            if let error = response.error as NSError? {
//                // Extracting the message from userInfo
//                if let errorMessage = error.userInfo["message"] as? String {
//                    print("Error: \(errorMessage)")
//                    completion(false, errorMessage)
//                } else {
//                    print("Error", error)
//                }
//            } else {
//                print(response.result ?? "NO result")
//                completion(true, nil)
//            }
//            
//            return nil
//        }
//    }
//    
//    func confirmForgotPassword(email username: String, code: String, newPassword: String, completion: @escaping (Bool, String?) -> Void){
//        pool?.getUser(username).confirmForgotPassword(code, password: newPassword).continueWith{ (response) -> Any? in
//            if let error = response.error as NSError? {
//                // Extracting the message from userInfo
//                if let errorMessage = error.userInfo["message"] as? String {
//                    print("Error: \(errorMessage)")
//                    completion(false, errorMessage)
//                } else {
//                    print("Error", error)
//                }
//            } else {
//                print(response.result ?? "NO result")
//                completion(true, nil)
//            }
//            
//            return nil
//        }
//    }
//    
//    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
//        pool?.currentUser()?.changePassword(currentPassword, proposedPassword: newPassword).continueWith{ (response) -> Any? in
//            if let error = response.error as NSError? {
//                // Extracting the message from userInfo
//                if let errorMessage = error.userInfo["message"] as? String {
//                    print("Error: \(errorMessage)")
//                    completion(false, errorMessage)
//                } else {
//                    print("Error", error)
//                }
//            } else {
//                print(response.result ?? "NO result")
//                completion(true, nil)
//            }
//            
//            return nil
//        }
//    }
//    
//    func getSession() {
//        pool?.currentUser()?.getSession().continueWith(block: { (task) -> Any? in
//            if let session = task.result {
//                let accessToken = session.accessToken!.tokenString
//                let tokenID = session.idToken!.tokenString
//                let refreshToken = session.refreshToken!.tokenString
//                print("Access:", accessToken)
//                print("ID:", tokenID)
//                print("Refresh:", refreshToken)
//            }
//            
//            if let error = task.error {
//                print("Error", error)
//                print("Logging out")
//            } else {
//                print(task.result ?? "NO result")
//            }
//            return nil
//        })
//    }
//    
//    func getAccessToken(completion: @escaping (String?, Error?) -> Void) {
//        if let currentUser = pool?.currentUser() {
//            currentUser.getSession().continueWith { (task) -> AnyObject? in
//                if let error = task.error as NSError? {
//                    completion(nil, error)
//                } else if let session = task.result {
//                    let accessToken = session.accessToken?.tokenString
//                    completion(accessToken, nil)
//                }
//                return nil
//            }
//        }
//    }
//    
//    func getUserID() -> String? {
//        var userID: String? = nil
//        self.getAccessToken { accessToken, error in
//            if let token = accessToken{
//                let jwtToken = getDecodedJWTBody(token: token)
//                userID = jwtToken?.username
//            } else {
//                print(error ?? "Error Ocured in the getUserID")
//            }
//        }
//        
//       return userID
//    }
//    
//}
