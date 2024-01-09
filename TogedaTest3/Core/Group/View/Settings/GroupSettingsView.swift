//
//  GroupSettingsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import SwiftUI

struct GroupSettingsView: View {
    @ObservedObject var vm: GroupViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List{
            Section(header: Text("Group")){
                NavigationLink(destination: EditGroupView()){
                    Text("Edit Group")
                }
                NavigationLink(destination: GroupPermissionsView(selectedPermission: $vm.club.permissions)){
                    Text("Permissions")
                }
                NavigationLink(destination: GroupAccessibilityView(selectedVisability: $vm.club.visability, askToJoin: $vm.club.askToJoin)){
                    Text("Visability")
                }
            }
            Section(header: Text("More")){
                Button{
                    
                }label:{
                    Text("Leave")
                }
                Button{
                    
                }label:{
                    Text("Delete Group")
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
    GroupSettingsView(vm: GroupViewModel())
}
