//
//  InstagramStoryView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.09.24.
//

import SwiftUI
import Kingfisher

struct InstagramStoryView: View {
    @State  var isImageLoaded = false
    @Binding var screenshot: UIImage?
    var post = MockPost
    var body: some View {
        VStack{
            ZStack(alignment: .bottom){
                KFImage(URL(string: post.images[0]))
                    .onSuccess({ _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.screenshot = self.snapshot()
                        }
                    })
                    .resizable()
                    .aspectRatio(9/16, contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .cornerRadius(20)
//                    .onAppear {
//                        checkIfURLHasLoadedSynchronously(post.images[0]) { isLoaded in
//                            if isLoaded {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                    self.screenshot = self.snapshot()
//                                }
//                            }
//                        }
//                    }
                
                
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                    .opacity(0.95)
                    .frame(height: 500)
                
                VStack(spacing: 16){
                    
                    Text(post.title)
                        .font(.title)
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
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    HStack(alignment: .center){
                        Image(systemName: "location")
                            .font(.title3)
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
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white, lineWidth: 2)
                    )
                }
                .padding()
                .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea(.all)
    }
    
//    func checkIfURLHasLoadedSynchronously(_ urlString: String, completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            completion(false)
//            return
//        }
//
//        // Perform a lightweight URL check synchronously
//        let request = URLRequest(url: url)
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            if let error = error {
//                print("Error loading URL: \(error)")
//                completion(false)
//            } else if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }.resume()
//    }

}

#Preview {
    InstagramStoryView(screenshot: .constant(nil))
}
