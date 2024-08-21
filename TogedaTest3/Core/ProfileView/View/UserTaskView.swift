//
//  UserTaskView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 21.08.24.
//

import SwiftUI

struct UserTaskView: View {
    var badgeTask: Components.Schemas.BadgeTask
    var referralCode: String
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            
            //            HStack{
            //                Text("Badge: ")
            //                    .font(.body)
            //                    .fontWeight(.bold)
            //
            //                Text("🏅 Early Adopter")
            //                    .selectedTagTextStyle()
            //                    .padding(.horizontal, 10)
            //                    .padding(.vertical, 8)
            //                    .background{Capsule().fill(Color("main-secondary-color"))}
            //            }
            //
            
            VStack (alignment: .center) {
                Text("🏅")
                    .font(.custom("", size: 120))
                    .padding()
                    .background{
                        Circle().opacity(0.3)
                    }
                
                Text(badgeTask.title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            
            if let description = badgeTask.description, !description.isEmpty{
                HStack{
                    Text("Description: ")
                        .font(.body)
                        .fontWeight(.bold) +
                    
                    Text(description)
                        .foregroundStyle(.gray)
                    
                }
                .multilineTextAlignment(.leading)
            }
            
            Text("Invited Friends: (\(badgeTask.currentNumber ?? 0)/\(badgeTask.completionNumber ?? 10))")
                .font(.body)
                .fontWeight(.bold)
            
            ProgressView(value: 10, total: 20)
                .scaleEffect(CGSize(width: 1.0, height: 2.0))
            
            Text("Referral Code:")
                .font(.body)
                .fontWeight(.bold)
            
            HStack{
                Text(referralCode)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 13)
                    .background{RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color("main-secondary-color"))}
                
                Button{
                    UIPasteboard.general.string = referralCode
                } label:{
                    Text("Copy")
                        .font(.subheadline)
                        .foregroundStyle(Color("base"))
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: 100, alignment: .center)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 13)
                        .background{Color("blackAndWhite")}
                        .cornerRadius(10)
                }
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    UserTaskView(badgeTask: mockBadgeTask, referralCode: "12345678909876543")
}


