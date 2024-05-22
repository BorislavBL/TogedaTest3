//
//  EditProfilePhoneNumberMainView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.02.24.
//

import SwiftUI

struct EditProfilePhoneNumberMainView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var showVerify: Bool = false
    @State var code = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            if let user = userVM.currentUserOld {
                Text("Phone Number")
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "phone.fill")
                        .imageScale(.large)
                    
                    Text(user.phoneNumber.isEmpty ? "Add your number" : "+" + user.phoneNumber)
                    
                }
                .createEventTabStyle()
                
                if !user.verifiedPhone {
                    HStack{
                        Image(systemName: "x.circle")
                        Text("You still haven't verified your number.")
                            .font(.footnote)
                            .bold()
                    }
                    .foregroundStyle(.red)
                } else {
                    HStack{
                        Image(systemName: "checkmark.circle")
                        Text("Your phone number is verified")
                            .font(.footnote)
                            .bold()
                    }
                    .foregroundStyle(.green)
                }
                
                VStack(spacing: 16){
                    if !user.verifiedPhone {
                        NavigationLink(value: SelectionPath.editProfilePhoneCodeVerification){
                            Text("Verify")
                                .font(.subheadline)
                                .foregroundStyle(Color("base"))
                                .fontWeight(.semibold)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 13)
                                .background{Color("blackAndWhite")}
                                .cornerRadius(10)
                        }
                    }
                    
                    NavigationLink(value: SelectionPath.editProfilePhoneNumber){
                        Text("Change Number")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                }
                .padding(.top, 16)
                
            } else {
                ProgressView()
            }
        }
        .padding()
        .navigationTitle("Phone Number")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
}

#Preview {
    EditProfilePhoneNumberMainView()
        .environmentObject(UserViewModel())
}
