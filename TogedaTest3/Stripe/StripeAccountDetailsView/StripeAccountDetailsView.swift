//
//  CreateStripeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.06.24.
//

import SwiftUI

struct StripeAccountDetailsView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var bannerVM: BannerService
    
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    
    @State var openRemoveSheet: Bool = false
    var body: some View {
        ScrollView{
            LazyVStack(spacing: 10) {
                if let user = userVM.currentUser, user.stripeAccountId != nil {
                    StripeCard(isOnBoardingDone: userVM.isOnBoardingDone, stripeAccountInformation: userVM.userStripeAccountInformation, user: user)
                    
                    VStack(alignment: .leading, spacing: 10){
                        Text("Message")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .opacity(0.7)
                        
                        if !userVM.isOnBoardingDone {
                            Text("Your Stripe account has been created, but the setup isn't complete yet. Please visit the Stripe dashboard on their official website to finish your onboarding.")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .opacity(0.9)
                        } else {
                            Text("Your Stripe account is connected and ready to go.")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .opacity(0.9)
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.bar)
                    .cornerRadius(10)
                    
                    Button{
                        openURL(URL(string: "https://dashboard.stripe.com")!)
                    } label: {
                        Text("Go to Stripe")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                    }
                    
                } else {
                    StripeCard(isOnBoardingDone: false, user: MockUser)
                    VStack(alignment: .leading, spacing: 10){
                        Text("Message")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .opacity(0.7)
                        
                        Text("Hosting events? Now you can get paid! Connect with Stripe to sell tickets, collect payments, and get payouts straight to your bank—safe and hassle-free. Stripe handles the money so you can focus on creating experiences your community loves.")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .opacity(0.9)
                            
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.bar)
                    .cornerRadius(10)
                    
                    LoadingButton(action: {
                        Task{
                            if let accountId = try await APIClient.shared.createStripeAccount() {
                                print(accountId)
                                if let link = try await APIClient.shared.getStripeOnBoardingLink(accountId: accountId) {
                                    print(link)
                                    openURL(URL(string: link)!)
                                }
                            }
                        }
                    }) {
                        Text("Create account")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                    } loadingView: {
                        Text("Loading...")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            getAllStripeInfo()
        }
        .scrollIndicators(.hidden)
        .background(scheme == .dark ? Color(.clear) : Color("testColor"))
        .background(.thinMaterial)
        .navigationTitle("Stripe Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let user = userVM.currentUser, user.stripeAccountId != nil{
                    Button{
                        openRemoveSheet = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .imageScale(.medium)
                            .foregroundStyle(.red)
                            .frame(width: 35, height: 35)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                        .frame(width: 35, height: 35)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    
                }
            }
        }
        .sheet(isPresented: $openRemoveSheet, content: {
            onRemoveStripeTab()
        })
        .swipeBack()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("Is active triggered -------////=")
            getAllStripeInfo()
            
        }
        .onAppear(){
            getAllStripeInfo()
            
        }
    }
    
    func getAllStripeInfo() {
        Task {
            do {
                // 1) Fetch user FIRST
                try await userVM.fetchCurrentUser()

                // 2) Now safely unwrap values that may depend on the fetch
                guard let user = userVM.currentUser,
                      let id = user.stripeAccountId else {
                    print("No user or stripeAccountId after fetching.")
                    return
                }

                // 3) Run the rest concurrently
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        do { _ = try await userVM.stripeOnBordingStatus(accountId: id) }
                        catch { print("stripeOnBordingStatus error:", error) }
                    }
                    group.addTask {
                        do { _ = try await userVM.checkForPaidEvent() }
                        catch { print("checkForPaidEvent error:", error) }
                    }
                    group.addTask {
                        do { try await userVM.stripeAccountInformation() }
                        catch { print("stripeAccountInformation error:", error) }
                    }
                }
            } catch {
                print("fetchCurrentUser failed:", error)
            }
        }
    }

    
    func onRemoveStripeTab() -> some View {
        VStack(spacing: 30){
            if userVM.hasPaidEvents {
                Text("You cannot change your Stripe account while you have active paid events, as doing so could disrupt the payment process and affect the receipt of funds.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            } else {
                Text("Confirm disconnect: Are you sure you want to chnage your Stripe account?")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            LoadingButton(action: {
                do{
                    if let accountId = try await APIClient.shared.updateStripeAccount() {
                        print(accountId)
                        if let link = try await APIClient.shared.getStripeOnBoardingLink(accountId: accountId) {
                            print(link)
                            openURL(URL(string: link)!)
                        }
                    }
                } catch{
                    print(error)
                }
            }){
                Text("Change Stripe")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red)
                    .cornerRadius(10)
            } loadingView: {
                Text("Loading...")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red)
                    .cornerRadius(10)
            }
            .disableWithOpacity(userVM.hasPaidEvents)
        }
        .padding()
        .presentationDetents([.fraction(0.2)])
    }
}

struct StripeCard: View {
    var isOnBoardingDone: Bool
    var stripeAccountInformation: Components.Schemas.StripeAccountDto?
    var user: Components.Schemas.UserInfoDto
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        
        ZStack {
            PremiumAuroraBackground()
            if let id = user.stripeAccountId {
                if let account = stripeAccountInformation {
                    VStack(alignment: .leading, spacing: 10){
                        HStack(alignment: .top){
                            VStack(alignment: .leading, spacing: 10){
                                Text("Annual Revenue")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .opacity(0.7)
                                
                                Text("\(account.businessProfile?.annualRevenue?.currency?.uppercased() ?? account.defaultCurrency.uppercased()) \(account.businessProfile?.annualRevenue?.amount ?? 0)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.bottom)
                                Group{
                                    if let individual = account.individual {
                                        if let firstN = individual.firstName, let lastN = individual.lastName {
                                            Text("\(firstN) \(lastN)")
                                        } else {
                                            Text("\(user.firstName) \(user.lastName)")
                                        }
                                    } else if let business = account.businessProfile{
                                        if let businessN = business.name {
                                            Text("\(businessN)")
                                        } else {
                                            Text("\(user.firstName) \(user.lastName)")
                                        }
                                    } else {
                                        Text("\(user.firstName) \(user.lastName)")
                                        
                                    }
                                }
                                .font(.body)
                                .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 10){
                                Text("Status")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .opacity(0.7)
                                
                                HStack {
                                    if isOnBoardingDone {
                                        Circle()
                                            .foregroundStyle(.green)
                                            .frame(width: 12, height: 12)
                                        
                                        
                                        Text("Active")
                                            .font(.body)
                                            .fontWeight(.bold)
                                    } else {
                                        Circle()
                                            .foregroundStyle(.yellow)
                                            .frame(width: 12, height: 12)
                                        
                                        
                                        Text("Inactive")
                                            .font(.body)
                                            .fontWeight(.bold)
                                    }
                                }
                                .opacity(0.9)
                                
                            }
                        }
                        
                        Capsule()
                            .frame(height: 0.6)
                            .opacity(0.2)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10){
                            Text("Account")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .opacity(0.7)
                            
                            Text(account.email ?? account.individual?.email ?? "Uknown Account")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .padding(.bottom)
                                .opacity(0.9)
                        }
                        
                        
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 10){
                        HStack(alignment: .top){
                            VStack(alignment: .leading, spacing: 10){
                                Text("Status")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .opacity(0.7)
                                
                                HStack {
                                    if isOnBoardingDone {
                                        Circle()
                                            .foregroundStyle(.green)
                                            .frame(width: 12, height: 12)
                                        
                                        
                                        Text("Active")
                                            .font(.body)
                                            .fontWeight(.bold)
                                    } else {
                                        Circle()
                                            .foregroundStyle(.yellow)
                                            .frame(width: 12, height: 12)
                                        
                                        
                                        Text("Inactive")
                                            .font(.body)
                                            .fontWeight(.bold)
                                    }
                                }
                                .opacity(0.9)
                                .padding(.bottom)
                                
                                Text("\(user.firstName) \(user.lastName)")
                                
                                    .font(.body)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            Image("togeda-white-clear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 40, alignment: .center)
                                .opacity(0.7)
                            
                        }
                        
                        Capsule()
                            .frame(height: 0.6)
                            .opacity(0.2)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10){
                            Text("Account ID")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .opacity(0.7)
                            
                            Text(id)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .padding(.bottom)
                                .opacity(0.9)
                        }
                        
                        
                    }
                    .padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 10){
                    HStack(alignment: .top){
                        VStack(alignment: .leading, spacing: 10){
                            Text("Annual Revenue")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .opacity(0.7)
                            
                            Text("$0")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom)
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
                                Text("+ Add Stripe Account")
                                    .font(.body)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 10){
                            Text("Status")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .opacity(0.7)
                            
                            HStack {
                                Circle()
                                    .foregroundStyle(.yellow)
                                    .frame(width: 12, height: 12)
                                
                                Text("Inactive")
                                    .font(.body)
                                    .fontWeight(.bold)
                            }
                            .opacity(0.9)
                        }
                        
                    }
                    
                    Capsule()
                        .frame(height: 0.6)
                        .opacity(0.2)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10){
                        Text("Account")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .opacity(0.7)
                        
                        Text("Create a new or add an existing Stripe account and monetize your events.")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                            .opacity(0.9)
                    }
                    
                    
                }
                .padding()
            }
        }
        .tint(.white)
        .foregroundStyle(.white)
        .cornerRadius(10)
    }
}


#Preview {
    StripeAccountDetailsView()
        .environmentObject(UserViewModel())
        .environmentObject(BannerService())
    
}

//            if let user = userVM.currentUser {
//                if let id = user.stripeAccountId{
//                    VStack(spacing: 16){
//                        Text("Stripe ID: \(id)")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .multilineTextAlignment(.center)
//
//                        if userVM.isOnBoardingDone {
//                            HStack{
//                                Text("Status: Connected")
//                                    .font(.title2)
//                                    .fontWeight(.semibold)
//                                    .multilineTextAlignment(.center)
//
//                                Circle()
//                                    .foregroundStyle(.green)
//                                    .frame(width: 15, height: 15)
//                            }
//                        } else {
//                            HStack{
//                                Text("Status: Pending")
//                                    .font(.title2)
//                                    .fontWeight(.semibold)
//                                    .multilineTextAlignment(.center)
//
//                                Circle()
//                                    .foregroundStyle(.yellow)
//                                    .frame(width: 15, height: 15)
//                            }
//                        }
//
//                        if !userVM.isOnBoardingDone {
//                            Text("Your Stripe account has been created, but the setup isn't complete yet. Please visit the Stripe dashboard on their official website to finish your onboarding.")
//                                .font(.footnote)
//                                .fontWeight(.semibold)
//                                .multilineTextAlignment(.center)
//                                .padding()
//                        } else if userVM.hasPaidEvents {
//                            Text("You cannot change or remove your Stripe account while you have active paid events, as doing so could disrupt the payment process and affect the receipt of funds.")
//                                .font(.footnote)
//                                .fontWeight(.semibold)
//                                .multilineTextAlignment(.center)
//                                .padding()
//                        }
//
//                        Button{
//                            Task{
//                                if let accountId = try await APIClient.shared.updateStripeAccount() {
//                                    print(accountId)
//                                    if let link = try await APIClient.shared.getStripeOnBoardingLink(accountId: accountId) {
//                                        print(link)
//                                        openURL(URL(string: link)!)
//                                    }
//                                }
//                            }
//                        } label: {
//                            Text("Change Account")
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                                .padding()
//                                .padding(.horizontal)
//                                .background(Color(.blue).opacity(0.1))
//                                .cornerRadius(10)
//                        }
//                        .disableWithOpacity(userVM.hasPaidEvents)
//                        .padding(.top, 20)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(.bar)
//                    .cornerRadius(10)
//                    .padding()
//                } else {
//                    VStack(spacing: 16){
//                        Text("Create a new or add an existing Stripe account and monetize your events")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .multilineTextAlignment(.center)
//
//                        Button{
//                            Task{
//                                if let accountId = try await APIClient.shared.createStripeAccount() {
//                                    print(accountId)
//                                    if let link = try await APIClient.shared.getStripeOnBoardingLink(accountId: accountId) {
//                                        print(link)
//                                        openURL(URL(string: link)!)
//                                    }
//                                }
//                            }
//                        } label: {
//                            Text("Add Stripe Account")
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                                .padding()
//                                .padding(.horizontal)
//                                .background(Color(.green).opacity(0.1))
//                                .cornerRadius(10)
//                        }
//                        .padding(.top, 20)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(.bar)
//                    .cornerRadius(10)
//                    .padding()
//
//                }
//            }
            
