//
//  GroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI

struct GroupView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView{
            MainGroupView()
        }
        .frame(maxWidth: .infinity)
        .background(Color("testColor"))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 5) { // adjust the spacing value as needed
                    Button {
                        print("")
                    } label: {
                        Image(systemName: "plus.square")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }
                    
                    NavigationLink(destination: UserSettingsView()) {
                        Image(systemName: "gear")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    GroupView()
}
