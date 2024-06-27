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
    }
    @Environment(\.dismiss) var dismiss
    @State var selectedOption: InPersonViolation?
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
    InPersonUserReportView()
}
