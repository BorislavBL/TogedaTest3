//
//  ReportUserView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.06.24.
//

import SwiftUI

struct ReportUserView: View {
    var user: Components.Schemas.MiniUser
    @Environment(\.dismiss) var dismiss
    @State var showPhotoView = false
    @State var showFakeProfileView = false
    @State var fakeProfilDescription: String = ""
    @State var showImpersonationView = false
    @State var impersonationDescription: String = ""
    @State var showInPersonView = false
    @State var other = false
    @State var otherDescription: String = ""
    
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    Text("Report")
                        .bold()
                        .padding()
                    HStack{
                        Spacer()
                        Button{
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                Divider()
                
                Text("Your report is anonymus.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding()
                
                ScrollView{
                    LazyVStack(alignment:.leading){
                        Divider()
                        Button{
                            showPhotoView = true
                        } label: {
                            HStack(){
                                Text("Inappropriate photos")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        Button{
                            showFakeProfileView = true
                        } label: {
                            HStack(){
                                Text("Fake profile")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        Button{
                            showImpersonationView = true
                        } label: {
                            HStack(){
                                Text("Impersonation")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        Button{
                            showInPersonView = true
                        } label: {
                            HStack(){
                                Text("Something that they did in person")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        Button{
                            other = true
                        } label: {
                            HStack(){
                                Text("Other")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showPhotoView) {
                InappropriatePhotoReport()
            }
            .navigationDestination(isPresented: $showFakeProfileView) {
                GeneralSubmitReportView(title: "Report Case: Fake Profile", description: $fakeProfilDescription, onSubmit: {
                    
                })
            }
            .navigationDestination(isPresented: $showImpersonationView) {
                GeneralSubmitReportView(title: "Report Case: Impersonation", description: $impersonationDescription, onSubmit: {
                    
                })
            }
            .navigationDestination(isPresented: $showInPersonView) {
               InPersonUserReportView()
            }
            .navigationDestination(isPresented: $other) {
                GeneralSubmitReportView(title: "Report Case: Other", description: $otherDescription, onSubmit: {
                    
                })
            }
        }
    }
}

#Preview {
    ReportUserView(user: MockMiniUser)
}
