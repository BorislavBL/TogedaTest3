//
//  CreateStripeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.06.24.
//

import SwiftUI

struct CreateStripeView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack{
            if let user = userVM.currentUser {
                if user.stripeAccountId == nil {
                    Text("Create Stripe account and monetize your events")
                    
                    Button{
                        Task{
                            if let accountId = try await APIClient.shared.createStripeAccount() {
                                print(accountId)
                                if let link = try await APIClient.shared.getStripeOnBoardingLink(accountId: accountId) {
                                    print(link)
                                    openURL(URL(string: link)!)
                                }
                            }
                        }
                    } label: {
                        Text("Create account")
                    }
                } else {
                    Text("Has account")
                }
            }
        }
    }
    

}

#Preview {
    CreateStripeView()
        .environmentObject(UserViewModel())
}
