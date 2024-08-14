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
        
        func toString() -> String {
            switch self {
            case .hateSpeechOrHarassment:
                return "Promotes hate speech or harrassment"
            case .intellectualProperty:
                return "Intellectual property infingent"
            case .nudity:
                return "Nudity or sexual activity"
            case .violenceOrCrime:
                return "Promotes violence or criminal organizations"
            }
        }
    }
    
    var user: Components.Schemas.MiniUser?
    var club: Components.Schemas.ClubDto?
    var post: Components.Schemas.PostResponseDto?
    
    @Environment(\.dismiss) var dismiss
    @State var selectedOption: InappropriatePhoto?
    @State var success: Bool = false
    @State var displayWarrning: Bool = false
    @Binding var isActive: Bool
    
    
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
            .padding()
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
                    
                    if displayWarrning && selectedOption == nil {
                        WarningTextComponent(text: "Please select one of the option.")
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            if selectedOption != nil {
                Button {
                    submit()
                    
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
            } else {
                Text("Report")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .fontWeight(.semibold)
                    .cornerRadius(10)
                    .padding()
                    .onTapGesture {
                        displayWarrning.toggle()
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
        .swipeBack()
    }
    
    func submit() {
        if let option = selectedOption {
            let report: Components.Schemas.ReportDto = .init(
                reportType: .INAPPROPRIATE_PHOTOS,
                description: option.toString(),
                reportedUser: user?.id,
                reportedPost: post?.id,
                reportedClub: club?.id
            )
            
            Task{
                if let response = try await APIClient.shared.report(body: report) {
                    success = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isActive = false
                    }
                }
            }
        }
    }
    
}

#Preview {
    InappropriatePhotoReport(isActive: .constant(true))
}
