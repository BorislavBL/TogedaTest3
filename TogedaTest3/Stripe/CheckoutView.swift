import StripePaymentSheet
import SwiftUI

class MyBackendModel: ObservableObject {

    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var postId: String?
    
    func preparePaymentSheet() {
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        Task {
            do {
                if let id = postId, let request = try await APIClient.shared.getPaymentSheet(postId: id) {
                    print("Received request: \(request)")
                    STPAPIClient.shared.publishableKey = "pk_test_\(request.publishableKey)"
                    
                    STPAPIClient.shared.stripeAccount = request.ownerStripeAccountId
                    // MARK: Create a PaymentSheet instance
                    var configuration = PaymentSheet.Configuration()
                    configuration.merchantDisplayName = "Togeda Net"
                    configuration.returnURL = "https://www.togeda.net/"
                    configuration.applePay = .init(
                      merchantId: "merchant.net.togeda.ios",
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
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        self.paymentResult = result
    }
}

struct CheckoutView: View {
    @StateObject var model = MyBackendModel()
    var postId: String
    
    var body: some View {
        VStack {
            if let paymentSheet = model.paymentSheet {
                PaymentSheet.PaymentButton(
                    paymentSheet: paymentSheet,
                    onCompletion: model.onPaymentCompletion
                ) {
                    Text("Buy")
                }
            } else {
                Text("Loading…")
            }
            if let result = model.paymentResult {
                switch result {
                case .completed:
                    Text("Payment complete")
                case .failed(let error):
                    Text("Payment failed: \(error.localizedDescription)")
                        .onAppear(){
                            print("\(error)")
                        }
                case .canceled:
                    Text("Payment canceled.")
                }
            }
        }.onAppear {
            model.postId = postId
            model.preparePaymentSheet()
        }
    }
}

#Preview {
    CheckoutView(postId: "")
}
