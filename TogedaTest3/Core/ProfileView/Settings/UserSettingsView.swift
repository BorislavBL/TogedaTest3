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
    var body: some View {
        List{
            Section(header: Text("Profile")){
                NavigationLink(value: SelectionPath.editProfile){
                    Text("Edit Profile")
                }
                NavigationLink(value: SelectionPath.test){
                    Text("Privacy Settings")
                }
                NavigationLink(value: SelectionPath.test){
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
                    
                }label:{
                    Text("Delete Account")
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
    }
}

#Preview {
    UserSettingsView()
        .environmentObject(ContentViewModel())
}
