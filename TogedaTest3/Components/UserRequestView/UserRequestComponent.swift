//
//  UserRequestComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.05.24.
//

import SwiftUI
import Kingfisher

struct UserRequestComponent: View {
    private let size: ImageSize = .medium
    var user: Components.Schemas.MiniUser
    var expiration: Int64?
    var confirm: () -> ()
    var delete: () -> ()
    
    var body: some View {
        NavigationLink(value: SelectionPath.profile(user)){
            HStack(alignment:.top){
                KFImage(URL(string: user.profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                
            }
            VStack(alignment:.leading){
                HStack{
                    HStack(spacing: 5) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        if user.userRole == .AMBASSADOR {
                            AmbassadorSealMini()
                        } else if user.userRole == .PARTNER {
                            PartnerSealMini()
                        }
                    }
                    
                    if let date = expiration {
                        Spacer()
                        
                        Text(daysLeft(from: date))
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
                
                
                HStack(alignment:.center, spacing: 10) {
                    Button {
                        confirm()
                    } label: {
                        Text("Confirm")
                            .normalTagTextStyle()
                            .frame(maxWidth: .infinity)
                            .normalTagRectangleStyle()
                    }
                    Button {
                        delete()
                    } label: {
                        Text("Delete")
                            .normalTagTextStyle()
                            .frame(maxWidth: .infinity)
                            .normalTagRectangleStyle()
                    }
                }
            }
            .multilineTextAlignment(.leading)
        }
    }
    
    private func daysLeft(from interval: Int64) -> String {
        // Get the current date
        let currentDate = Date()
        
        // Convert the interval to a Date object (since interval is seconds since 1970)
        let targetDate = Date(timeIntervalSince1970: TimeInterval(interval))
        
        // Calculate the difference between the target date and the current date
        let daysLeft = Calendar.current.dateComponents([.day], from: currentDate, to: targetDate).day ?? 0
        
        // Ensure the result is not negative (if the date has passed)
        if daysLeft <= 0 {
            return "0 days left"
        } else {
            return "\(daysLeft) days left"
        }
    }
}

#Preview {
    UserRequestComponent(user: MockMiniUser, confirm: {}, delete: {})
}
