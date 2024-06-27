//
//  GeneralSubmitReportView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.06.24.
//

import SwiftUI

struct GeneralSubmitReportView: View {
    @Environment(\.dismiss) var dismiss
    var title: String
    var caseDescription: String?
    @Binding var description: String
    var onSubmit: ()->()
    
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
                    Text(title)
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    if let caseDescription = caseDescription {
                        ExpandableText(caseDescription, lineLimit: 4)
                            .lineSpacing(8.0)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                    }
                    
                    
                    VStack(alignment: .leading){
                        Text("Would you like to tell us more?")
                            .font(.body)
                            .fontWeight(.bold)
                        TextField("Comment", text: $description, axis: .vertical)
                            .lineLimit(15, reservesSpace: true)
                            .padding()
                            .background{Color("main-secondary-color")}
                            .cornerRadius(10)
                    }
                    .padding()
                    
                }
                
                
            }
            .scrollIndicators(.hidden)
            
            Button {
                onSubmit()
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
    GeneralSubmitReportView(title: "Report Case: Slavery", description: .constant(""), onSubmit: {})
}
