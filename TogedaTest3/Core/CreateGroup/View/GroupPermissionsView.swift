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
    
    var body: some View{
        VStack(alignment: .leading, spacing: 20){
            VStack(alignment: .leading){
                Button{
                    selectedPermission = .All_members
                } label:{
                    HStack {
                        if selectedPermission == .All_members {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .imageScale(.large)
                                .foregroundStyle(.gray)
                        }
                        Text("All Members").tag(Permissions.All_members)
                    }
                }
                
                HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                    
                    Text("Everyone in this group will be able to create events.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading){
                Button{
                    selectedPermission = .Admins_only
                } label:{
                    HStack {
                        if selectedPermission == .Admins_only {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .imageScale(.large)
                                .foregroundStyle(.gray)
                        }
                        Text("Admins only").tag(Permissions.Admins_only)
                    }
                }
                
                HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                    
                    Text("Only admins will be capable of creating group events.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .swipeBack()
        .navigationTitle("Permissions")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
        }
        )
        
        
    }

}

#Preview {
    GroupPermissionsView(selectedPermission: .constant(.All_members))
}
