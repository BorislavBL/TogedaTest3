//
//  UserSettingsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI

struct UserSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List{
            Section(header: Text("Profile")){
                NavigationLink(destination: TestView()){
                    Text("Edit Profile")
                }
                NavigationLink(destination: TestView()){
                    Text("Privacy Settings")
                }
                NavigationLink(destination: TestView()){
                    Text("Payment Methods")
                }
            }
            Section(header: Text("Togeda")){
                NavigationLink(destination: TestView()){
                    Text("Website")
                }
                NavigationLink(destination: TestView()){
                    Text("Instagram")
                }
                NavigationLink(destination: TestView()){
                    Text("Linked in")
                }
                NavigationLink(destination: TestView()){
                    Text("Contact us")
                }
            }
            Section(header: Text("About")){
                NavigationLink(destination: TestView()){
                    Text("Privacy Policy")
                }
                NavigationLink(destination: TestView()){
                    Text("Terms of Use")
                }
                NavigationLink(destination: TestView()){
                    Text("Licenses")
                }
            }
            
            Section(header: Text("More")){
                Button{
                    
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
}
