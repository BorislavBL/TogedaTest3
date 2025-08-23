//
//  EventCheckoutSheet.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.09.24.
//

import SwiftUI
import Kingfisher
import StripePaymentSheet

struct EventCheckoutSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var post: Components.Schemas.PostResponseDto
    @State var paymentFee: Components.Schemas.PostFeeResponseDto?
    @StateObject var paymentVM = StripeAccountViewModel()
    @EnvironmentObject var postsViewModel: PostsViewModel
    @Binding var isActive: Bool
    var refreshParticipants: () -> ()
    
    var body: some View {
        VStack{
            navbar()
            
            HStack(alignment: .top){
                KFImage(URL(string: post.images[0]))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                VStack{
                    Text(post.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    HStack{
                        Text("Price: ")
                        Spacer()
                        if post.payment > 0 {
                            Text("\(post.currency?.symbol ?? "€") \(post.payment, specifier: "%.2f")")
                        } else {
                            Text("Free")
                        }
                    }
                    .foregroundStyle(.gray)
                }
                .padding()
                
            }
            .background(Color("blackAndWhite").opacity(0.1))
            .cornerRadius(10)
            .frame(height: 120)
            .padding(.horizontal)
            
            if let fee = paymentFee, fee.postPrice > 0 {
                VStack(alignment: .leading, spacing: 10){
                    
                    HStack{
                        Text("Subtotal: ")
                        
                        Spacer()
                        
                        Text("\(post.currency?.symbol ?? "€")  \(fee.postPrice, specifier: "%.2f")")

                    }
                    
                    HStack{
                        Text("Estimated tax: ")
                        
                        Spacer()
                        
                        Text("\(post.currency?.symbol ?? "€")  \((fee.stripeFee + fee.togedaFee), specifier: "%.2f")")

                    }
                    
                    Divider()
                    
                    HStack{
                        Text("Total: ")
                        
                        Spacer()
                        
                        Text("\(post.currency?.symbol ?? "€")  \((fee.totalPrice), specifier: "%.2f")")

                    }
                    .fontWeight(.bold)
                    
                    if post.askToJoin {
                        Spacer()
                        HStack(alignment: .top){
                            Image(systemName: "exclamationmark.triangle")
                            
                            Text("Request a ticket, and once the organizer approves, your ticket will be automatically purchased!")
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.bottom)
                        .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 32)
            }
            
            if let error = paymentVM.error {
                WarningTextComponent(text: error)
                    .padding()
            } else if maxParticipantsReached {
                WarningTextComponent(text: "Oh no, tickets are sold out! But keep an eye out—if someone cancels, you’ll have the chance to grab their spot. Stay ready to snag a ticket if it opens up!")
                    .padding()
            } else if post.status != .NOT_STARTED {
                WarningTextComponent(text: "The event has already started.")
                    .padding()
            }
            
            Spacer()
            
            VStack {
                if post.status == .NOT_STARTED && !maxParticipantsReached {
                    if let paymentSheet = paymentVM.paymentSheet {
                        if let result = paymentVM.paymentResult {
                            switch result {
                            case .completed:
                                Text("Payment complete.")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                                    .padding()
                                    .onAppear(){
                                        Task{
                                            if let response = try await APIClient.shared.getEvent(postId: post.id){
                                                postsViewModel.localRefreshEventOnAction(post: response)
                                                
                                                refreshParticipants()
                                                
                                                post = response
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    
                                                    isActive = false
                                                }
                                            }
                                            
                                        }
                                    }
                            case .failed(let error):
                                Text("Payment failed.")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                                    .onAppear(){
                                        paymentVM.error = error.localizedDescription
                                    }
                                    .padding()
                                
                            case .canceled:
                                Text("Payment canceled.")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                                    .onAppear(){
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            isActive = false
                                        }
                                    }
                                    .padding()
                                
                            }
                        } else {
                            PaymentSheet.PaymentButton(
                                paymentSheet: paymentSheet,
                                onCompletion: paymentVM.onPaymentCompletion
                            ) {
                                Text("Pay")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                                
                            }
                            .padding()
                            
                            
                        }
                        
                    }
                    else {
                        Text("Loading…")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .padding()
                        
                    }
                } else {
                    Text("Payment Locked")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .onAppear(){
            Task {
                if let response = try await APIClient.shared.paidEventFees(postId: post.id) {
                    paymentFee = response
                }
                paymentVM.eventID = post.id
                paymentVM.preparePaymentSheet()
                
                if let resposne = try await APIClient.shared.getEvent(postId: post.id) {
                    post = resposne
                    postsViewModel.localRefreshEventOnAction(post: resposne)
                }
            }
        }
    }
    
    var maxParticipantsReached: Bool {
        if let max = post.maximumPeople{
            if max <= post.participantsCount{
                return true
            }
        }
        return false
    }
    
    @ViewBuilder
    func navbar() -> some View {
        HStack{
            Spacer()
            Button{ dismiss() } label:{
                Image(systemName: "xmark")
                    .frame(width: 35, height: 35)
                    .background(.bar)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
        }
        .padding()
        .overlay(alignment: .center) {
            Text("Checkout")
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    EventCheckoutSheet(post: .constant(MockPost), isActive: .constant(true), refreshParticipants: {})
        .environmentObject(PostsViewModel())
}
