//
//  EventReviewView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI

struct EventReviewView: View {
    @Environment(\.dismiss) var dismiss
    @State var rating: Int = 0
    
    var post: Post = Post.MOCK_POSTS[0]
    @State var description: String = ""
    
    let placeholder = "Share your experience...\nTell us what you thought about the event. What was the highlight for you? Was there anything that could be improved? Your feedback helps others decide which events to attend and assists organizers in making future events even better. Whether it’s the atmosphere, the music, the people, or the venue, let us know your thoughts! \nRemember to keep your review respectful and constructive – everyone reads these!"
    
    var body: some View {
        ZStack(alignment:.bottom){
            ScrollView{
                LazyVStack(alignment:.center, spacing: 30){
                    Image(post.imageUrl[0])
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .cornerRadius(10)
                        .clipped()
                    
                    Text(post.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    RatingButtonView(rating: $rating, onColor: Color.yellow, dimension: 25, spacing: 10)
                    
                    VStack(alignment: .leading){
                        Text("Comment")
                            .font(.body)
                            .fontWeight(.bold)
                        TextField(placeholder, text: $description, axis: .vertical)
                            .lineLimit(20, reservesSpace: true)
                    }
                    .padding()
                    .frame(minWidth: UIScreen.main.bounds.width, alignment: .leading)
                    
                }
                .padding()
            }
            
            VStack(){
                Divider()
                
                NavigationLink(destination: ReviewMemoriesView()) {
                    HStack(spacing:2){
                        
                            Text("Next")
                                .fontWeight(.semibold)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                }
                .padding()
            }
            .background(.bar)
        
        }
        .navigationTitle("Rating")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
}


#Preview {
    EventReviewView()
}
