//
//  AccesabilityView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.09.23.
//

import SwiftUI

struct AccessibilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedVisability: String
    @Binding var askToJoin: Bool
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
//            Text("Accessibility")
//                .font(.title3)
//                .fontWeight(.bold)
//                .listRowSeparator(.hidden)

            VStack(alignment: .leading){
                Button{
                    selectedVisability = "PUBLIC"
                } label:{
                    HStack {
                        if selectedVisability == "PUBLIC"{
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .imageScale(.large)
                                .foregroundStyle(.gray)
                        }
                        Text("Public").tag("PUBLIC")
                    }
                }
                
                HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                    
                    Text("Everyone will be able see your event.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading){
                
                Button{
                    selectedVisability = "PRIVATE"
                } label:{
                    HStack{
                        if selectedVisability == "PRIVATE"{
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .imageScale(.large)
                                .foregroundStyle(.gray)
                        }
                        Text("Private").tag("PRIVATE")
                    }
                }
                
                HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                    
                    Text("Your event won't be visable for everyone. In this case you will eaither have to invite them or attach the event to a club so that only club members could see it.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading){
                Toggle(isOn: $askToJoin) {
                    Text("Ask for permission")
                        .fontWeight(.semibold)
                }
                
                Text("Each user will have to be approved by you in order to join.")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            
            if userVM.user.details.clubIds.count > 0 {
                VStack(alignment: .leading){
                    Text("Is this a personal or club event?")
                        .fontWeight(.semibold)
                    
                    AccessibilityEventType(user: userVM.user)
                }
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Accessibility")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
        }
        )
        
        
    }
}

struct AccessibilityEventType: View {
    var user: User
    var clubs = Club.MOCK_CLUBS
    var size: ImageSize = .small
    @State var showOptions: Bool = false
    @State var selectedClubID: String?
    @State var selectedClub: Club?
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button{
                showOptions.toggle()
            } label: {
                HStack{
                    if let club = selectedClub{
                        Image(club.imagesUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                        Text(club.title)
                            .fontWeight(.semibold)
                    } else {
                        Text("Personal Event")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    
                    Image(systemName: showOptions ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            
            if showOptions{
                ForEach(clubs, id: \.id) {club in
                    Button{
                        selectedClubID = club.id
                        selectedClub = club
                        showOptions = false
                    } label:{
                        Image(club.imagesUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                        
                        Text(club.title)
                            .fontWeight(.semibold)
                    }
                }
                
                Divider()
                
                Button{
                    selectedClubID = nil
                    selectedClub = nil
                    showOptions = false
                } label: {
                    Text("Personal Event")
                        .fontWeight(.semibold)
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading )
        .padding(16)
        .background(Color(.tertiarySystemFill))
        .cornerRadius(10.0)
        .frame(maxHeight: .infinity, alignment: .top )
    }
}

struct AccessibilityView_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityView(selectedVisability: .constant("PUBLIC"), askToJoin: .constant(true))
            .environmentObject(UserViewModel())
    }
}
