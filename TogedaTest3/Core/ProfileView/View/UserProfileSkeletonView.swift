//
//  UserProfileSkeletonView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.02.24.
//

import SwiftUI

struct UserProfileSkeletonView: View {
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack{
                Rectangle()
                    .blinking(duration: 0.75)
//                    .skeleton(with: true, shape: .rectangle)
                    .frame(height: 500)
                
                
                VStack(spacing: 10) {
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true)
                        .frame(height: 16)
                    
                    
                    HStack(spacing: 5){
                        Rectangle()
                            .blinking(duration: 0.75)
//                            .skeleton(with: true)
                        
                        Rectangle()
                            .blinking(duration: 0.75)
//                            .skeleton(with: true)
                    }
                    .frame(height: 16)
                    
                    
                    HStack(spacing: 5){
                        Rectangle()
                            .blinking(duration: 0.75)
//                            .skeleton(with: true)
                        
                        Rectangle()
                            .blinking(duration: 0.75)
//                            .skeleton(with: true)
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .frame(height: 16)
                    
                }
                .padding()
                
                HStack(alignment: .top, spacing: 30) {
                    Rectangle()
                        .blinking(duration: 0.75)
                        .cornerRadius(10)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                    
                    Rectangle()
                        .blinking(duration: 0.75)
                        .cornerRadius(10)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                    
                    Rectangle()
                        .blinking(duration: 0.75)
                        .cornerRadius(10)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                }
                .frame(height: 100)
                .padding()
                
                
                HStack(alignment:.center, spacing: 10) {
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true)
                        .frame(height: 30)
                    
                    
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true)
                        .frame(height: 30)
                }
                .padding(.horizontal)
                
            }
            .padding(.bottom)
            .frame(width: UIScreen.main.bounds.width)
            .background(.bar)
            .cornerRadius(10)
            
            VStack (alignment: .leading) {
                HStack{
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true)
                        .frame(height: 16)
                    
                    Spacer()
                    
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true)
                        .frame(height: 16)
                    
                }
                .padding(.horizontal)
                VStack(alignment: .leading){
                    HStack(spacing: 10){
                        ForEach(0..<4, id: \.self){index in
                            Circle()
                                .blinking(duration: 0.75)
//                                .skeleton(with: true, shape: .circle)
                                .frame(width: 70, height: 70)
                            
                        }
                    }
                    .padding(.leading)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical)
            .background(.bar)
            .cornerRadius(10)
            
            VStack (alignment: .leading) {
                
                Rectangle()
                    .blinking(duration: 0.75)
//                    .skeleton(with: true)
                    .frame(height: 16)

                HStack(){
                    ForEach(0..<3, id: \.self){_ in
                        Capsule()
                            .blinking(duration: 0.75)
//                            .skeleton(with: true)
                            .frame(width: 100, height: 30)
                    }
                    
                }.padding(.bottom, 30)
                
                Rectangle()
                    .blinking(duration: 0.75)
//                    .skeleton(with: true)
                    .frame(height: 16)
                
                HStack(){
                    ForEach(0..<3, id: \.self){_ in
                        Capsule()
                            .blinking(duration: 0.75)
//                            .skeleton(with: true)
                            .frame(width: 100, height: 30)
                    }
                    
                }.padding(.bottom, 30)
                
                Rectangle()
                    .blinking(duration: 0.75)
//                    .skeleton(with: true)
                    .frame(height: 16)
                
                HStack(){
                    ForEach(0..<3, id: \.self){_ in
                        Capsule()
                            .blinking(duration: 0.75)
//                            .skeleton(with: true)
                            .frame(width: 100, height: 30)
                    }
                    
                }
                .padding(.bottom, 8)
                
                
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(.bar)
            .cornerRadius(10)
            
            //                        if let user = user {
            //                            AboutTab(user: user)
            //                        }
            //            EventTab(userID: miniUser.id)
            //            ClubsTab(userID: miniUser.id)
            
            
        }
        .edgesIgnoringSafeArea(.top)
        .frame(maxWidth: .infinity)
        .background(Color("testColor"))
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        
    }
    
}
#Preview {
    UserProfileSkeletonView()
}
