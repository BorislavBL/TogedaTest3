//
//  AllEventTabsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.06.24.
//

import SwiftUI
import Kingfisher

struct AllEventTabsView: View {
    @ObservedObject var eventVM: EventViewModel
    var post: Components.Schemas.PostResponseDto
    var club: Components.Schemas.ClubDto?
    
    var body: some View {
        VStack(alignment: .leading){
            if let club = self.club {
                NavigationLink(value: SelectionPath.club(club)){
                    HStack(alignment: .center, spacing: 10) {
                        KFImage(URL(string:club.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(club.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Club Event")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .normalTagRectangleStyle()
                }
            }
            
            Group{
                
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "calendar")
                        .imageScale(.large)
                    if let from = post.fromDate {
                        VStack(alignment: .leading, spacing: 5) {
                            
                            if let to = post.toDate{
                                Text("\(separateDateAndTime(from: from).date) - \(separateDateAndTime(from: to).date)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("\(separateDateAndTime(from: from).time) - \(separateDateAndTime(from: to).time)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                            } else {
                                Text("\(separateDateAndTime(from: from).date)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(separateDateAndTime(from: from).time)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                            }
                            
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 5) {
                            
                            Text("Any Day")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("There is no fixed Date&Time.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "mappin.circle")
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        
                        Text(locationCityAndCountry(post.location))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if !post.askToJoin || post.currentUserStatus == .PARTICIPATING {
                            if let address = post.location.address {
                                Text(address)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                            } else {
                                Text(post.location.name)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                            }
                        } else {
                            Text("The exact location will be revealed upon joining.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                        
                    }
                }
                
                if post.needsLocationalConfirmation {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "location.fill.viewfinder")
                            .imageScale(.large)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Confirm Location")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("You will have to confirm your attendace once you reach the destination via the app. Failing to do so may result in being marked as a no-show.")
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                NavigationLink(value: SelectionPath.usersList(post: post)){
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "person.2")
                            .imageScale(.large)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            if let maxPeople = post.maximumPeople {
                                Text("Participants \(eventVM.participantsCount)/\(maxPeople)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            } else {
                                Text("Participants \(eventVM.participantsCount)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            
                            if eventVM.participantsList.count > 0 {
                                ZStack{
                                    ForEach(Array(eventVM.participantsList.enumerated()), id: \.element.user.id){ index, item in
                                        
                                        if index < 4 {
                                            KFImage(URL(string: item.user.profilePhotos[0]))
                                                .resizable()
                                                .background(.gray)
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipped()
                                                .cornerRadius(100)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color("main-secondary-color"), lineWidth: 2)
                                                )
                                                .offset(x:CGFloat(20 * index))
                                        }
                                        
                                    }
                                    
                                    if eventVM.participantsList.count > 4 {
                                        
                                        Circle()
                                            .fill(.gray)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                ZStack(alignment:.center){
                                                    Text("+\(eventVM.participantsList.count - 3)")
                                                        .font(.caption2)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                    Circle()
                                                        .stroke(Color("main-secondary-color"), lineWidth: 2)
                                                }
                                            )
                                            .offset(x:CGFloat(20 * 4))
                                    }
                                }
                                
                                
                            }
                        }
                    }
                }
                
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "globe.europe.africa.fill")
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(post.accessibility.rawValue.capitalized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        switch post.accessibility {
                        case .PRIVATE:
                            Text("Only the people invited by the owner can join the event.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                            
                        case .PUBLIC:
                            Text("Everyone can join the event")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }

                    }
                }
                
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "wallet.pass")
                    //                                    .resizable()
                    //                                    .scaledToFit()
                    //                                    .frame(width: 25, height: 25)
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        if post.payment <= 0 {
                            Text("Free")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("No payment required")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        } else {
                            Text("Paid")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("$ \(String(format: "%.2f", post.payment)) per person")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .normalTagRectangleStyle()
        }
    }
}

#Preview {
    AllEventTabsView(eventVM: EventViewModel(), post: MockPost, club: MockClub)
}
