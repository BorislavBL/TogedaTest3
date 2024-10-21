//
//  UserSettingsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI

struct UserSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainVM: ContentViewModel
    @State var paidEventMessage = false
    @State var deleteSheet = false
    var body: some View {
        List{
            Section(header: Text("Profile")){
                NavigationLink(value: SelectionPath.editProfile){
                    Text("Edit Profile ")
                }
//                NavigationLink(value: SelectionPath.test){
//                    Text("Privacy Settings")
//                }
                NavigationLink(value: SelectionPath.paymentPage){
                    Text("Payment Methods")
                }
            }
            Section(header: Text("Togeda")){
                NavigationLink(value: SelectionPath.test){
                    Text("Website")
                }
                Button{
                    if let url = URL(string: "https://www.instagram.com/togeda_net/") {
                        UIApplication.shared.open(url)
                    }
                } label:{
                    Text("Instagram")
                }
                Button{
                    if let url = URL(string: "https://discord.gg/e4uzckuK") {
                        UIApplication.shared.open(url)
                    }
                } label:{
                    Text("Discord")
                }
                NavigationLink(value: SelectionPath.test){
                    Text("Linked in")
                }
                NavigationLink(value: SelectionPath.test){
                    Text("Contact us")
                }
            }
            Section(header: Text("About")){
                NavigationLink(value: SelectionPath.test){
                    Text("Privacy Policy")
                }
                NavigationLink(value: SelectionPath.test){
                    Text("Terms of Use")
                }
                NavigationLink(value: SelectionPath.test){
                    Text("Licenses")
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
                .presentationDetents([.fraction(0.4)])
            
        })
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
}
