//
//  ProfileInstagramStoryView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.12.24.
//

import SwiftUI
import Kingfisher

struct ProfileInstagramStoryView: View {
    var user: Components.Schemas.UserInfoDto
    var body: some View {
        VStack{
            ZStack(alignment: .bottom){
                KFImage(URL(string: user.profilePhotos[0]))
                    .resizable()
                    .aspectRatio(9/16, contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .cornerRadius(20)
                
                
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                    .opacity(0.70)
                    .frame(height: 600)
                
                
                switch user.userRole {
                case .NORMAL:
                    VStack(spacing: 16){
                        Image("togeda-white-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 50, alignment: .center)
                            
                        
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Find me on Togeda!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                                                   
                        HStack{
                            Text("Place your LINK here")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white, lineWidth: 2)
                        )
                    }
                    .padding()
                    .padding(.bottom, 180)
                case .ADMINISTRATOR:
                    VStack(spacing: 16){
                        Image("togeda-white-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 50, alignment: .center)
                            
                        
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Find me on Togeda!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                                                   
                        HStack{
                            Text("Place your LINK here")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white, lineWidth: 2)
                        )
                    }
                    .padding()
                    .padding(.bottom, 180)
                case .PARTNER:
                    VStack(spacing: 10){
                        VStack(spacing: 5){
                            Image("togeda-white-logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 50, alignment: .center)
                            
                            Text("x")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.title)
                                .foregroundStyle(.white)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                        
                        Text("PARTNERS")
                            .font(.title)
                            .foregroundStyle(
                                CommodityColor.silverLight.linearGradient
                            )
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                                                   
                        HStack{
                            Text("Place your LINK here")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white, lineWidth: 2)
                        )
                    }
                    .padding()
                    .padding(.bottom, 180)
                case .AMBASSADOR:
                    VStack(spacing: 16){
                        Image("togeda-white-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 50, alignment: .center)
                        
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Ambassador")
                            .font(.title)
                            .foregroundStyle(
                                CommodityColor.gold.linearGradient
                            )
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                                                   
                        HStack{
                            Text("Place your LINK here")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white, lineWidth: 2)
                        )
                    }
                    .padding()
                    .padding(.bottom, 180)
                }
                
            }
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ProfileInstagramStoryView(user: MockUser)
}
