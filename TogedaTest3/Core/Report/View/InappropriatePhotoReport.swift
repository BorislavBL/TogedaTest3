//
//  InappropriatePhotoReport.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.06.24.
//

import SwiftUI

struct InappropriatePhotoReport: View {
    enum InappropriatePhoto {
        case hateSpeechOrHarassment
        case intellectualProperty
        case nudity
        case violenceOrCrime
    }
    
    var user: Components.Schemas.MiniUser?
    var club: Components.Schemas.ClubDto?
    var post: Components.Schemas.PostResponseDto?
    
    @Environment(\.dismiss) var dismiss
    @State var selectedOption: InappropriatePhoto?
    
    
    var body: some View {
        VStack(spacing: 0){
            ZStack{
                Text("Report")
                    .bold()
                    .padding(8)
                HStack{
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            
            Divider()
            
            ScrollView{
                LazyVStack(alignment:.leading){
                    Text("Tell us more! What makes it inappropriate?")
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    Button{
                        selectedOption = .hateSpeechOrHarassment
                    } label:{
                        HStack{
                            if selectedOption == .hateSpeechOrHarassment {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Promotes hate speech or harrassment").tag(InappropriatePhoto.hateSpeechOrHarassment)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .nudity
                    } label:{
                        HStack{
                            if selectedOption == .nudity {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Nudity or sexual activity").tag(InappropriatePhoto.nudity)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .intellectualProperty
                    } label:{
                        HStack{
                            if selectedOption == .intellectualProperty {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Intellectual property infingent").tag(InappropriatePhoto.intellectualProperty)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .violenceOrCrime
                    } label:{
                        HStack{
                            if selectedOption == .violenceOrCrime {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Promotes violence or criminal organizations").tag(InappropriatePhoto.violenceOrCrime)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            Button {

            } label: {
            Text("Report")
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color("blackAndWhite"))
                .foregroundColor(Color("testColor"))
                .fontWeight(.semibold)
                .cornerRadius(10)
                
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .swipeBack()
    }
}

#Preview {
    InappropriatePhotoReport()
}
