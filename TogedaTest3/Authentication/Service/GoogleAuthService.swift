//
//  GoogleAuthService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.02.24.
//


import SwiftUI
import GoogleSignIn

class GoogleAuthService: ObservableObject {
    /// An enumeration representing logged in status.
    enum State {
      /// The user is logged in and is the associated value of this case.
      case signedIn(GIDGoogleUser)
      /// The user is logged out.
      case signedOut
    }
    
    @Published var state: State?
    @Published var givenName: String = ""
    @Published var emailAddress: String = ""
    @Published var fullName: String = ""
    @Published var familyName: String = ""
    @Published var profilePicUrl: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    init(){
        check()
    }
    
    func checkStatus(){
        if(GIDSignIn.sharedInstance.currentUser != nil){
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            self.fullName = user.profile?.name ?? ""
            self.givenName = user.profile?.givenName ?? ""
            self.familyName = user.profile?.familyName ?? ""
            self.profilePicUrl = user.profile?.imageURL(withDimension: 320)?.absoluteString ?? ""
            self.emailAddress = user.profile?.email ?? ""
            
            self.isLoggedIn = true
            self.state = .signedIn(user)
        } else{
            self.isLoggedIn = false
            self.givenName = "Not Logged In"
            self.profilePicUrl =  ""
            self.state = .signedOut
        }
        
        print("fullName: \(fullName) \n familyName: \(familyName) \n givenName: \(givenName) \n email: \(emailAddress) \n profileImg: \(profilePicUrl)")
    }
    
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
    
    func signIn(){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Ensure the window scene has at least one window
            if let rootViewController = windowScene.windows.first?.rootViewController {
                // Present the Google Sign In flow
                GIDSignIn.sharedInstance.signIn(
                  withPresenting: rootViewController) { signInResult, error in
                      guard error == nil else { return }
//                      guard let signInResult = signInResult else { return }

//                      let user = signInResult.user
                      
                      self.checkStatus()
//                      self.emailAddress = user.profile?.email ?? ""
//                      self.fullName = user.profile?.name ?? ""
//                      self.givenName = user.profile?.givenName ?? ""
//                      self.familyName = user.profile?.familyName ?? ""
//                      self.profilePicUrl = user.profile?.imageURL(withDimension: 320)?.absoluteString ?? ""
                  }
            }
        }
        
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
}


///// A class conforming to `ObservableObject` used to represent a user's authentication status.
//final class AuthenticationViewModel: ObservableObject {
//  /// The user's log in status.
//  /// - note: This will publish updates when its value changes.
//  @Published var state: State
//  private var authenticator: GoogleSignInAuthenticator {
//    return GoogleSignInAuthenticator(authViewModel: self)
//  }
//  /// The user-authorized scopes.
//  /// - note: If the user is logged out, then this will default to empty.
//  var authorizedScopes: [String] {
//    switch state {
//    case .signedIn(let user):
//      return user.grantedScopes ?? []
//    case .signedOut:
//      return []
//    }
//  }
//
//  /// Creates an instance of this view model.
//  init() {
//    if let user = GIDSignIn.sharedInstance.currentUser {
//      self.state = .signedIn(user)
//    } else {
//      self.state = .signedOut
//    }
//  }
//
//  /// Signs the user in.
//  func signIn() {
//    authenticator.signIn()
//  }
//
//  /// Signs the user out.
//  func signOut() {
//    authenticator.signOut()
//  }
//
//  /// Disconnects the previously granted scope and logs the user out.
//  func disconnect() {
//    authenticator.disconnect()
//  }
//
//}
//
//extension AuthenticationViewModel {
//  /// An enumeration representing logged in status.
//  enum State {
//    /// The user is logged in and is the associated value of this case.
//    case signedIn(GIDGoogleUser)
//    /// The user is logged out.
//    case signedOut
//  }
//}
//
///// An observable class for authenticating via Google.
//final class GoogleSignInAuthenticator: ObservableObject {
//  private var authViewModel: AuthenticationViewModel
//
//  /// Creates an instance of this authenticator.
//  /// - parameter authViewModel: The view model this authenticator will set logged in status on.
//  init(authViewModel: AuthenticationViewModel) {
//    self.authViewModel = authViewModel
//  }
//
//  /// Signs in the user based upon the selected account.'
//  /// - note: Successful calls to this will set the `authViewModel`'s `state` property.
//  func signIn() {
//    guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
//      print("There is no root view controller!")
//      return
//    }
//
//    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
//      guard let signInResult = signInResult else {
//        print("Error! \(String(describing: error))")
//        return
//      }
//      self.authViewModel.state = .signedIn(signInResult.user)
//    }
//
//  }
//
//  /// Signs out the current user.
//  func signOut() {
//    GIDSignIn.sharedInstance.signOut()
//    authViewModel.state = .signedOut
//  }
//
//  /// Disconnects the previously granted scope and signs the user out.
//  func disconnect() {
//    GIDSignIn.sharedInstance.disconnect { error in
//      if let error = error {
//        print("Encountered error disconnecting scope: \(error).")
//      }
//      self.signOut()
//    }
//  }
//
//}
//
//
//func handleSignInButton() {
//    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//        // Ensure the window scene has at least one window
//        if let rootViewController = windowScene.windows.first?.rootViewController {
//            // Present the Google Sign In flow
//            GIDSignIn.sharedInstance.signIn(
//              withPresenting: rootViewController) { signInResult, error in
//                  guard error == nil else { return }
//                  guard let signInResult = signInResult else { return }
//
//                  let user = signInResult.user
//
//                  let emailAddress = user.profile?.email
//
//                  let fullName = user.profile?.name
//                  let givenName = user.profile?.givenName
//                  let familyName = user.profile?.familyName
//
//                  let profilePicUrl = user.profile?.imageURL(withDimension: 320)
//              }
//        }
//    }
//}
