//
//  InstagramStoryView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.09.24.
//

import SwiftUI
import Kingfisher

struct InstagramStoryView: View {
    @State var isImageLoaded = false
    var post: Components.Schemas.PostResponseDto
    var body: some View {
        VStack{
            ZStack(alignment: .bottom){
                KFImage(URL(string: post.images[0]))
                    .resizable()
                    .aspectRatio(9/16, contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .cornerRadius(20)
                
                
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                    .opacity(0.95)
                    .frame(height: 600)
                
                VStack(spacing: 16){
                    
                    Text(post.title)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    HStack(){
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundStyle(.white)
                        if let fromDate = post.fromDate{
                            
                            if let toDate = post.toDate, separateDateAndTime(from: fromDate).date != separateDateAndTime(from: toDate).date{
                                Text("\(separateDateAndTime(from: fromDate).date) - \(separateDateAndTime(from: toDate).date)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            } else {
                                Text("\(separateDateAndTime(from: fromDate).date)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        } else {
                            Text("Anyday")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    HStack(alignment: .center){
                        Image(systemName: "location")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text(locationCityAndCountry(post.location))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
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
        .ignoresSafeArea(.all)
    }
    


}

#Preview {
    InstagramStoryView(post: MockPost)
}
