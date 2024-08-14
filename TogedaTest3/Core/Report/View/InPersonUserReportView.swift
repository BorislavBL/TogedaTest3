//
//  InPersonUserReportView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.06.24.
//

import SwiftUI

struct InPersonUserReportView: View {
    enum InPersonViolation {
        case harassment
        case physicallyHurt
        case other
        
        func toString() -> String {
            switch self {
            case .harassment:
                return "I was harrased"
            case .physicallyHurt:
                return "I was physically hurt"
            case .other:
                return ""
            }
        }
    }
    @Environment(\.dismiss) var dismiss
    @State var selectedOption: InPersonViolation?
    @State var description: String = ""
    @State var displayWarrning: Bool = false
    var user: Components.Schemas.MiniUser
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
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            
            Divider()
            
            ScrollView{
                LazyVStack(alignment:.leading){
                    Text("Tell us what happened?")
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    Button{
                        selectedOption = .harassment
                    } label:{
                        HStack{
                            if selectedOption == .harassment {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("I was harrased").tag(InPersonViolation.harassment)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .physicallyHurt
                    } label:{
                        HStack{
                            if selectedOption == .physicallyHurt {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("I was physically hurt").tag(InPersonViolation.physicallyHurt)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    
                    Button{
                        selectedOption = .other
                    } label:{
                        HStack{
                            if selectedOption == .other {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Other").tag(InPersonViolation.other)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    if selectedOption == .other {
                        VStack(alignment: .leading){
                            Text("Tell us what happend?")
                                .font(.body)
                                .fontWeight(.bold)
                            TextField("Comment", text: $description, axis: .vertical)
                                .lineLimit(8, reservesSpace: true)
                                .padding()
                                .background{Color("main-secondary-color")}
                                .cornerRadius(10)
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
    
    func submit(){
        if let options = selectedOption {
            let report: Components.Schemas.ReportDto = .init(
                reportType: .ISSUE_IN_PERSON,
                description: options != .other ? options.toString() : description,
                reportedUser: user.id,
                reportedPost: nil,
                reportedClub: nil
            )
            
            Task{
                if let response = try await APIClient.shared.report(body: report) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isActive = false
                    }
                }
            }
        }
    }
}

#Preview {
    InPersonUserReportView(user: MockMiniUser, isActive: .constant(true))
}
