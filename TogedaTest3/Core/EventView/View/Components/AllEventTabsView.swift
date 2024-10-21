//
//  AllEventTabsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.06.24.
//

import SwiftUI
import Kingfisher
import EventKit

struct AllEventTabsView: View {
    @ObservedObject var eventVM: EventViewModel
    var post: Components.Schemas.PostResponseDto
    var club: Components.Schemas.ClubDto?
    @Binding var event: EKEvent?
    @Binding var store: EKEventStore
    
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
            
            if let from = post.fromDate {
                Button {
                    if isGoogleCalendarInstalled() {
                        print("This one")
                        eventVM.openCalendarSheet = true
                    } else {
                        print("That one")
                        if let fromDate = post.fromDate {
                            eventVM.openCalendarSheet = false
                            event = EKEvent(eventStore: store)
                            event?.title = post.title
                            event?.location = post.location.name
                            event?.startDate = fromDate
                            event?.endDate = post.toDate ?? fromDate.addingTimeInterval(3600)
                            event?.notes = post.description ?? "Event in Togeda."
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                eventVM.showAddEvent = true
                            }
                        }
                    }
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "calendar")
                            .imageScale(.large)
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
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .normalTagRectangleStyle()
                }
            } else {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "calendar")
                        .imageScale(.large)
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
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .normalTagRectangleStyle()
            }
            
            Button {
                if !post.askToJoin || post.currentUserStatus == .PARTICIPATING{
                    if isGoogleMapsInstalled() {
                        eventVM.openMapSheet = true
                    } else {
                        let url = URL(string: "maps://?saddr=&daddr=\(post.location.latitude),\(post.location.longitude)")
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    }
                }
            } label:{
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
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .normalTagRectangleStyle()
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
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .normalTagRectangleStyle()
            }
            
            NavigationLink(value: SelectionPath.usersList(post: post)){
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "person.2")
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        if let maxPeople = post.maximumPeople {
                            Text("Participants \(formatBigNumbers(Int(eventVM.participantsCount)))/\(formatBigNumbers(Int(maxPeople)))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        } else {
                            Text("Participants \(formatBigNumbers(Int(eventVM.participantsCount)))")
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
                                                Text("+\(formatBigNumbers(Int(eventVM.participantsList.count - 3)))")
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
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .normalTagRectangleStyle()
            }
            
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "globe.europe.africa.fill")
                    .imageScale(.large)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5){
                        Text(post.accessibility.rawValue.capitalized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        if post.askToJoin {
                            Text("(Ask To Join)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    switch post.accessibility {
                    case .PRIVATE:
                        Text("Only invited guests can join this event.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                        
                    case .PUBLIC:
                        if post.askToJoin {
                            Text("This event is open to the public, but you'll need approval from the organizer to join.")
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        } else {
                            Text("Everyone can join the event.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }
                    
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .normalTagRectangleStyle()
            
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
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .normalTagRectangleStyle()
        }
    }
}

#Preview {
    AllEventTabsView(eventVM: EventViewModel(), post: MockPost, club: MockClub, event: .constant(nil), store: .constant(EKEventStore()))
}
