//
//  GroupPermissionsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.12.23.
//

import SwiftUI

enum Permissions: Hashable, Codable {
    case All_members
    case Admins_only
    
    var value : String {
      switch self {
      // Use Internationalization, as appropriate.
      case .All_members: return "All members"
      case .Admins_only: return "Admins only"
     
      }
    }
    
    var backendValue : String {
      switch self {
      // Use Internationalization, as appropriate.
      case .All_members: return "ALL"
      case .Admins_only: return "ADMINS_ONLY"
     
      }
    }
}

struct GroupPermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPermission: Permissions
    
    var body: some View {
        List {
            Text("Permissions")
                .font(.title3)
                .fontWeight(.bold)
                .listRowSeparator(.hidden)

            
            Picker("", selection: $selectedPermission) {
                Text("All members").tag(Permissions.All_members)
                Text("Admins only").tag(Permissions.Admins_only)
            }
            .labelsHidden()
            .pickerStyle(InlinePickerStyle())
            
            Group{
                if selectedPermission == .All_members {
                    Text("Everyone in this group will be able to create events.")
                    
                } else if selectedPermission == .Admins_only {
                    Text("Only admins will be capable of creating group events.")
                }
            }
            .font(.callout)
            .foregroundColor(.gray)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .padding(.vertical)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        }
        )
        
        
    }
}

#Preview {
    GroupPermissionsView(selectedPermission: .constant(.All_members))
}
