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
    
    let placeholder = "Describe the purpose of your event. What activities are you planning? Mention any special guests who might be attending. Will there be food and drinks? Help attendees know what to expect."
    
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
                
                Button {

                } label: {
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
