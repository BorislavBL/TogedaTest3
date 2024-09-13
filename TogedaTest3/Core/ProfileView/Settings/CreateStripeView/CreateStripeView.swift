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
    @State var hasPaidEvents: Bool = true
    var body: some View {
        VStack{
            if let user = userVM.currentUser {
                if let id = user.stripeAccountId{
                    VStack(spacing: 16){
                        Text("Stripe ID: \(id)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        HStack{
                            Text("Status: Connected")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            
                            Circle()
                                .foregroundStyle(.green)
                                .frame(width: 15, height: 15)
                        }
                        
                        Text("You cannot change or remove your Stripe account while you have active paid events, as doing so could disrupt the payment process and affect the receipt of funds.")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button{
                            Task{
                                if let accountId = try await APIClient.shared.updateStripeAccount() {
                                    print(accountId)
                                    if let link = try await APIClient.shared.getStripeOnBoardingLink(accountId: accountId) {
                                        print(link)
                                        openURL(URL(string: link)!)
                                    }
                                }
                            }
                        } label: {
                            Text("Change Account")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding()
                                .padding(.horizontal)
                                .background(Color(.blue).opacity(0.1))
                                .cornerRadius(10)
                        }
                        .disableWithOpacity(hasPaidEvents)
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.bar)
                    .cornerRadius(10)
                    .padding()
                } else {
                    VStack(spacing: 16){
                        Text("Create a new or add an existing Stripe account and monetize your events")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
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
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding()
                                .padding(.horizontal)
                                .background(Color(.green).opacity(0.1))
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.bar)
                    .cornerRadius(10)
                    .padding()
                    
                }
            }


        }
        .swipeBack()
        .onAppear(){
            if let user = userVM.currentUser, let id = user.stripeAccountId{
                Task{
                    if let response = try await APIClient.shared.checkForPaidEvents() {
                        if let bool = Bool(response.data) {
                            hasPaidEvents = bool
                        }
                    }
                }
            }
        }
    }
    

}

#Preview {
    CreateStripeView()
        .environmentObject(UserViewModel())
}
