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
    }
    @Environment(\.dismiss) var dismiss
    @State var selectedOption: ScamReport?
    @State var description: String = ""
    
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
    }
}

#Preview {
    EventScamReportView()
}
