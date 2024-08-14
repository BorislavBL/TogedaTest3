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
    
    @Binding var isActive: Bool
    
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
                InappropriatePhotoReport(user: user, isActive: $isActive)
            }
            .navigationDestination(isPresented: $showFakeProfileView) {
                GeneralSubmitReportView(title: "Report Case: Fake Profile", description: $fakeProfilDescription, onSubmit: {
                    let report: Components.Schemas.ReportDto = .init(
                        reportType: .FAKE_PROFILE,
                        description: fakeProfilDescription,
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
                })
            }
            .navigationDestination(isPresented: $showImpersonationView) {
                GeneralSubmitReportView(title: "Report Case: Impersonation", description: $impersonationDescription, onSubmit: {
                    let report: Components.Schemas.ReportDto = .init(
                        reportType: .IMPERSONATION,
                        description: impersonationDescription,
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
                })
            }
            .navigationDestination(isPresented: $showInPersonView) {
                InPersonUserReportView(user: user, isActive: $isActive)
            }
            .navigationDestination(isPresented: $other) {
                GeneralSubmitReportView(title: "Report Case: Other", description: $otherDescription, onSubmit: {
                    let report: Components.Schemas.ReportDto = .init(
                        reportType: .OTHER,
                        description: otherDescription,
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
                })
            }
        }
    }
}

#Preview {
    ReportUserView(user: MockMiniUser, isActive: .constant(false))
}
