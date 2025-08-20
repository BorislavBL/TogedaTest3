//
//  AccountViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.06.24.
//

import Foundation
import StripePaymentSheet
import SwiftUI

class StripeAccountViewModel: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var eventID: String?
    @Published var error: String?
    @Published var showCheckout: Bool = false
    
    func preparePaymentSheet() {
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        Task {
            if let id = eventID {
                do {
                    if let request = try await APIClient.shared.getPaymentSheet(postId: id) {
                        print("Received request: \(request)")
                        //pk_test_
                        STPAPIClient.shared.publishableKey = "\(request.publishableKey)"
                        
                        STPAPIClient.shared.stripeAccount = request.ownerStripeAccountId
                        // MARK: Create a PaymentSheet instance
                        var configuration = PaymentSheet.Configuration()
                        configuration.merchantDisplayName = "Togeda Net"
                        configuration.returnURL = "https://www.togeda.net/"
                        configuration.applePay = .init(
                          merchantId: "merchant.net.togeda.app",
                          merchantCountryCode: "BG"
                        )
                        // configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
                        configuration.allowsDelayedPaymentMethods = true
                        
                        DispatchQueue.main.async {
                            self.paymentSheet = PaymentSheet(paymentIntentClientSecret: request.clientSecret, configuration: configuration)
                            print("PaymentSheet created")
                        }
                    } else {
                        print("Failed to fetch payment sheet details")
                    }
                } catch {
                    print("Error fetching payment sheet details: \(error)")
                }
            }
        }
    }
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        self.paymentResult = result
    }
}

