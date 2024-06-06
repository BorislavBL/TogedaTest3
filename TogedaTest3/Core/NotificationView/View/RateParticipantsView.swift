//
//  RateParticipantsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.06.24.
//

import SwiftUI
import Kingfisher

struct RateParticipantsView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    @StateObject var eventVM = EventViewModel()
    
    @State var isLoading = false
    
    var post: Components.Schemas.PostResponseDto
    @State var showUserLike = false
    @State var showUserReport = false
    @State var selectedExtendedUser: Components.Schemas.ExtendedMiniUser?
    @State var Init: Bool = true
    @State var description: String = ""
    
    var body: some View {
        VStack{
        ScrollView{
            Text("What do you think of the people from this event?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            LazyVStack(alignment:.leading){
                ForEach(eventVM.participantsList, id:\.user.id) { user in
                    HStack{
                        NavigationLink(value: SelectionPath.profile(user.user)){
                            HStack{
                                KFImage(URL(string: user.user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading){
                                    Text("\(user.user.firstName) \(user.user.lastName)")
                                        .fontWeight(.semibold)
                                    if user._type == .CO_HOST || user._type == .HOST {
                                        Text(user._type.rawValue.capitalized)
                                            .foregroundColor(.gray)
                                            .fontWeight(.semibold)
                                            .font(.footnote)
                                    }
                                    
                                }
                                
                                Spacer()
                                
                                Button{
                                    showUserReport = true
                                    selectedExtendedUser = user
                                } label: {
                                    Image(systemName: "hand.thumbsup")
                                        .foregroundStyle(.green)
                                }
                                
                                Button{
                                    showUserReport = true
                                    selectedExtendedUser = user
                                } label:{
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.red)
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    .padding(.vertical, 5)
                }
                
                if isLoading{
                    ProgressView()
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !eventVM.listLastPage {
                            isLoading = true
                            
                            Task{
                                try await eventVM.fetchUserList(id: post.id)
                                isLoading = false
                                
                            }
                        }
                    }
            }
            .padding(.horizontal)
            
        }
        VStack(){
            Divider()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing:2){
                    
                        Text("Finish")
                            .fontWeight(.semibold)
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color("blackAndWhite"))
                .foregroundColor(Color("testColor"))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(.bar)
        }
        .sheet(isPresented: $showUserLike, content: {
            VStack{
                if let user = selectedExtendedUser {
                    Text("You gave \(user.user.firstName) a like!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading){
                        Text("Tell us what you liked about this person?")
                            .font(.body)
                            .fontWeight(.bold)
                        
                        TextField("(Optional)", text: $description, axis: .vertical)
                            .lineLimit(10, reservesSpace: true)
                            .padding()
                            .background{Color("main-secondary-color")}
                            .cornerRadius(10)
                        
                    }
                    .padding()
                    .frame(minWidth: UIScreen.main.bounds.width, alignment: .leading)
                    
                    Spacer()
                    
                    Button{
                        if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == user.user.id }) {
                            eventVM.participantsList.remove(at: index)
                            dismiss()
                        }
                        
                    } label: {
                        HStack(spacing:2){
                            
                            Text("Send")
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                    }
                    .padding()

                }
            }
        })
        .onAppear(){
            Task{
                do{
                    if Init {
                        try await eventVM.fetchUserList(id: post.id)
                        Init = false
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
}

#Preview {
    RateParticipantsView(post: MockPost)
}
