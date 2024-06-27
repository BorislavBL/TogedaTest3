//
//  AccesabilityView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.09.23.
//

import SwiftUI
import Kingfisher

struct AccessibilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedVisability: String
    @Binding var askToJoin: Bool
    @Binding var selectedClub: Components.Schemas.ClubDto?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            VStack(alignment: .leading){
                Button{
                    selectedVisability = "PUBLIC"
                } label:{
                    HStack {
                        if selectedVisability == "PUBLIC" {
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
            
            VStack(alignment: .leading){
                Text("Is this a personal or club event?")
                    .fontWeight(.semibold)
                
                AccessibilityEventType(selectedClub: $selectedClub)
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
    var size: ImageSize = .small
    @State var showOptions: Bool = false
    @Binding var selectedClub: Components.Schemas.ClubDto?
    
    @State var Init: Bool = true
    
    @State var clubs: [Components.Schemas.ClubDto] = []
    @State var page: Int32 = 0
    @State var pageSize: Int32 = 10
    @State var lastPage = true
    @State var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button{
                showOptions.toggle()
                if showOptions && Init {
                    Task{
                        if let resposne = try await APIClient.shared.getClubsWithCreatePostPermission(page:page ,size: pageSize) {
                            clubs = resposne.data
                            lastPage = resposne.lastPage
                            
                            page += 1
                            Init = false
                        }
                    }
                }
            } label: {
                HStack{
                    if let club = selectedClub {
                        KFImage(URL(string: club.images[0]))
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
                if clubs.count > 0 {
                    ForEach(clubs, id: \.id) {club in
                        Button{
                            selectedClub = club
                            showOptions = false
                        } label:{
                            KFImage(URL(string: club.images[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .cornerRadius(10)
                                .clipped()
                            
                            Text(club.title)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    if isLoading {
                        ProgressView()
                    }
                    
                    Rectangle()
                        .frame(width: 0, height: 0)
                        .onAppear {
                            if !lastPage{
                                isLoading = true
                                Task{
                                    if let resposne = try await APIClient.shared.getClubsWithCreatePostPermission(page:page ,size: pageSize) {
                                        clubs = resposne.data
                                        lastPage = resposne.lastPage
                                        
                                        page += 1
                                        isLoading = false
                                    }
                                }
                                
                                
                                
                            }
                        }
                    
                    Divider()
                    
                    Button{
                        selectedClub = nil
                        showOptions = false
                    } label: {
                        Text("Personal Event")
                            .fontWeight(.semibold)
                    }
                    
                } else {
                    Text("No Clubs")
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
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
        AccessibilityView(selectedVisability: .constant("PUBLIC"), askToJoin: .constant(true), selectedClub: .constant(nil))
    }
}
