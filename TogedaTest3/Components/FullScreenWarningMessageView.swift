//
//  FullScreenWarningMessageView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.07.25.
//

import SwiftUI

struct FullScreenWarningMessageView: View {
    @Binding var isActive: Bool
    var icon: String?
    var image: Image?
    var title: String?
    var description: String
    var buttonName: String
    var action: () -> ()
    var isCancelButton: Bool = false
    var body: some View {
        ZStack{
            Color(.black).opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isActive = false
                    }
                }
            
            VStack(spacing: 10){
                if let i = icon {
                    Text(i)
                        .font(.custom("", size: 24))
                } else if let img = image {
                    img
                        .resizable()
                        .scaledToFit()
                        .frame(CGSize(width: 120, height: 120))
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(CGSize(width: 120, height: 120))
                    
                }
                if let t = title {
                    Text(t)
                        .font(.title3)
                        .bold()
                }
                
                Text(description)
                    .multilineTextAlignment(.center)
                    .bold()
                    .padding(.vertical, 5)
                    .opacity(0.7)
                    .font(description.count > 25 ? .body : .subheadline)
                
                Button{
                    action()
                } label:{
                    Text(buttonName)
                        .font(.subheadline)
                        .foregroundStyle(Color("base"))
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 13)
                        .background{Color("blackAndWhite")}
                        .cornerRadius(10)
                }
                
                if isCancelButton {
                    Button{
                        isActive = false
                    } label:{
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundStyle(Color("blackAndWhite").opacity(0.8))
                            .fontWeight(.semibold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .background{Color("blackAndWhite").opacity(0.2)}
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(.bar)
            .cornerRadius(20)
            .padding(32)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
    }
}

#Preview {
    FullScreenWarningMessageView(isActive: .constant(true), image:  Image(systemName: "creditcard.trianglebadge.exclamationmark.fill"), title: "Action Required", description: "To create a paid event, you must complete the setup of your Stripe account!", buttonName: "Go To Stripe", action: {})
}
