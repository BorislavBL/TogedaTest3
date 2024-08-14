//
//  EventScamReportView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.06.24.
//

import SwiftUI

struct EventScamReportView: View {
    enum ScamReport {
        case paymentScam
        case didNotHappened
        case misleadingInformation
        case alternativePayment
        case theHostWasNotThere
        case other
        
        func toString() -> String {
            switch self {
            case .paymentScam:
                return "The event did not happened and I was charged"
            case .didNotHappened:
                return "The event did not happened"
            case .misleadingInformation:
                return "Misleading title or content"
            case .alternativePayment:
                return "The event promotes alternative payment methods"
            case .theHostWasNotThere:
                return "The Host did not show up"
            case .other:
                return ""
            }
        }
    }
    @Environment(\.dismiss) var dismiss
    @State var selectedOption: ScamReport?
    @State var description: String = ""
    @Binding var isActive: Bool
    var post: Components.Schemas.PostResponseDto
    
    @State var displayWarrning: Bool = false
    
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
                    Text("How did they scam you?")
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    Button{
                        selectedOption = .paymentScam
                    } label:{
                        HStack{
                            if selectedOption == .paymentScam {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("The event did not happened and I was charged").tag(ScamReport.paymentScam)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .didNotHappened
                    } label:{
                        HStack{
                            if selectedOption == .didNotHappened {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("The event did not happened").tag(ScamReport.didNotHappened)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .misleadingInformation
                    } label:{
                        HStack{
                            if selectedOption == .misleadingInformation {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Misleading title or content").tag(ScamReport.misleadingInformation)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .alternativePayment
                    } label:{
                        HStack{
                            if selectedOption == .alternativePayment {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("The event promotes alternative payment methods").tag(ScamReport.alternativePayment)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding()
                    }
                    
                    Button{
                        selectedOption = .theHostWasNotThere
                    } label:{
                        HStack{
                            if selectedOption == .theHostWasNotThere {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("The Host did not show up").tag(ScamReport.theHostWasNotThere)
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
                            Text("Other").tag(ScamReport.other)
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
                reportType: .SCAM,
                description: options != .other ? options.toString() : description,
                reportedUser: nil,
                reportedPost: post.id,
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
    EventScamReportView(isActive: .constant(true), post: MockPost)
}
