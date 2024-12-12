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
    var badgesLeft: Components.Schemas.BadgeSupplyDto
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
                Text(badgeTask.badge?.image ?? "🏅")
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
            } else if let badge = badgeTask.badge, let description = badge.description{
                VStack(alignment: .leading){
                    Text("Description:")
                        .font(.body)
                        .fontWeight(.bold)
                    
                    Text(description)
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
            }
            
            Text("\(badgeTask.counterName): (\(badgeTask.currentNumber)/\(badgeTask.completionNumber))")
                .font(.body)
                .fontWeight(.bold)
            
            ProgressView(value: Float(badgeTask.currentNumber), total: Float(badgeTask.completionNumber))
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
            
            if badgeTask.title == "Early Adopter" {
                Text("Badges Left: \(badgesLeft.earlyAdopterBadgesLeft ?? 0)")
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .font(.footnote)
            } else if badgeTask.title == "Super User" {
                Text("Badges Left: \(badgesLeft.superUserBadgesLeft ?? 0)")
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .font(.footnote)
            }
            
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    UserTaskView(badgeTask: mockBadgeTask, referralCode: "12345678909876543", badgesLeft: .init(superUserBadgesLeft: 0, earlyAdopterBadgesLeft: 0))
}


