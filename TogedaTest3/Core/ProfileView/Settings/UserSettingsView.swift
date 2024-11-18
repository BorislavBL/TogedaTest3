//
//  UserSettingsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI
import MessageUI

struct UserSettingsView: View {
    var isSupportNeeded: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainVM: ContentViewModel
    @EnvironmentObject var userVm: UserViewModel
    @State var paidEventMessage = false
    @State var deleteSheet = false
    @State private var showMailView = false
    @State private var showAlert = false
    
    
    var body: some View {
        List{
            Section(header: Text("Profile")){
                NavigationLink(value: SelectionPath.editProfile){
                    Text("Edit Profile")
                }
//                NavigationLink(value: SelectionPath.test){
//                    Text("Privacy Settings")
//                }
                NavigationLink(value: SelectionPath.paymentPage){
                    Text("Payment Methods")
                }
                NavigationLink(value: SelectionPath.blockedUsers){
                    Text("Blocked Users")
                }
            }
            Section(header: Text("Togeda")){
                Button{
                    if let url = URL(string: TogedaLinks().website) {
                        UIApplication.shared.open(url)
                    }
                } label:{
                    Text("Website")
                }
                Button{
                    if let url = URL(string: TogedaLinks().instagram) {
                        UIApplication.shared.open(url)
                    }
                } label:{
                    Text("Instagram")
                }
//                Button{
//                    if let url = URL(string: "https://discord.gg/e4uzckuK") {
//                        UIApplication.shared.open(url)
//                    }
//                } label:{
//                    Text("Discord")
//                }
//                NavigationLink(value: SelectionPath.test){
//                    Text("Linked in")
//                }
                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        showMailView = true
                    } else {
                        showAlert = true
                    }
                }) {
                    Text("Contact us")
                }
            }
            Section(header: Text("About")){
                Button{
                    if let url = URL(string: TogedaLinks().privacyPolicy) {
                        UIApplication.shared.open(url)
                    }
                } label:{
                    Text("Privacy Policy")
                }
                Button{
                    if let url = URL(string: TogedaLinks().termsOfUse) {
                        UIApplication.shared.open(url)
                    }
                } label:{
                    Text("Terms of Use")
                }
            }
            
            Section(header: Text("More")){
                Button{
                    mainVM.logout()
                }label:{
                    Text("Log out")
                }
                
                Button{
                    deleteSheet = true
                } label:{
                    Text("Delete Account")
                }
            }
            
            if let build = mainVM.getBuildNumber(), let version = mainVM.getAppVersion(){
                VStack{
                    Image("TogedaLogo")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .scaledToFill()
                        .cornerRadius(20)
                        .clipped()
                        .padding(.bottom)
                    
                    Text("Version \(version) (\(build))")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .sheet(isPresented: $deleteSheet, content: {

                VStack(spacing: 30){
                    Text("Once you click 'Delete Account' your account will be permanently removed and cannot be recovered.")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if paidEventMessage{
                        WarningTextComponent(text: "You currently have one or more active paid events. Please complete them before proceeding.")
                    }
                    
                    Button{
                        Task {
                            if let response = try await APIClient.shared.checkForPaidEvents() {
                                if let bool = Bool(response.data), bool {
                                    paidEventMessage = true
                                } else {
                                    if let response = try await APIClient.shared.deleteUser(), response{
                                        mainVM.logout()
                                    }
                                }
                            }

                        }
                    } label:{
                        Text("Delete Account")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .presentationDetents([.height(250)])
            
        })
        .sheet(isPresented: $showMailView) {
            MailView(recipient: "togeda.info@gmail.com", user: userVm.currentUser)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("No Email Accounts"),
                message: Text("Please configure an email account in the Mail app to send an email or contact us at info@togeda.net using other platform.."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear(){
            if isSupportNeeded {
                if MFMailComposeViewController.canSendMail() {
                    showMailView = true
                } else {
                    showAlert = true
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .swipeBack()
    }
}

#Preview {
    UserSettingsView()
        .environmentObject(ContentViewModel())
        .environmentObject(UserViewModel())
}
