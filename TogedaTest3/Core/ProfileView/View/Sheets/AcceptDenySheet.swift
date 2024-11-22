//
//  AcceptDenySheet.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.06.24.
//

import SwiftUI

struct AcceptDenySheet: View {
    @Binding var showRespondSheet: Bool
    @Binding var user: Components.Schemas.UserInfoDto?
    var currentUser: Components.Schemas.UserInfoDto?

    var id: String
    
    var acceptEmoji: String {
        if currentUser?.gender == .MALE && user?.gender == .MALE {
            return "🤝"
        } else if currentUser?.gender == .MALE && user?.gender == .FEMALE {
            return "😉"
        } else if currentUser?.gender == .FEMALE && user?.gender == .FEMALE {
            return "✨"
        } else if currentUser?.gender == .FEMALE && user?.gender == .MALE {
            return "😎"
        } else {
            return "😁"
        }
    }
    
    var denyEmoji: String {
        if currentUser?.gender == .MALE && user?.gender == .MALE {
            return "🫡"
        } else if currentUser?.gender == .MALE && user?.gender == .FEMALE {
            return "🫠"
        } else if currentUser?.gender == .FEMALE && user?.gender == .FEMALE {
            return "🫣"
        } else if currentUser?.gender == .FEMALE && user?.gender == .MALE {
            return "🏋️"
        } else {
            return "😟"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Button{
                Task {
                    if try await APIClient.shared.respondToFriendRequest(toUserId: id, action:.ACCEPT) != nil {
                        self.user?.currentFriendshipStatus = .FRIENDS
                        showRespondSheet = false
                    }
                }
            } label: {
                HStack{
                    Text(acceptEmoji)
                    Text("Accept")
                        .fontWeight(.semibold)
                        .normalTagTextStyle()
                    
                    Spacer()
                    
//                    Image(systemName: "checkmark.circle.fill")
//                        .frame(width: 35, height: 35)
//                        .foregroundColor(Color("textColor"))
                    
     
                    

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background{Color("main-secondary-color")}
                .cornerRadius(10)
            }
            
            Button{
                Task {
                    if try await APIClient.shared.respondToFriendRequest(toUserId: id, action:.DENY) != nil {
                        self.user?.currentFriendshipStatus = .NOT_FRIENDS
                        showRespondSheet = false
                    }
                }
            } label: {
                HStack{
                    Text(denyEmoji)
                    Text("Deny")
                        .fontWeight(.semibold)
                        .normalTagTextStyle()
                    
                    Spacer()
                    
//                    Image(systemName: "x.circle.fill")
//                        .frame(width: 35, height: 35)
//                        .foregroundColor(Color("textColor"))
                    

                    

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background{Color("main-secondary-color")}
                .cornerRadius(10)
               
            }
        }
        .padding()
    }
}

#Preview {
    AcceptDenySheet(showRespondSheet: .constant(true), user: .constant(MockUser), currentUser: MockUser, id: "")
}
