//
//  EventReviewView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI
import Kingfisher

struct EventReviewView: View {
    @Environment(\.dismiss) var dismiss
    @State var rating: Int = 0
    @State var displayWarrning: Bool = false
    
    var post: Components.Schemas.PostResponseDto
    @State var description: String = ""
    
    let placeholder = "Share your experience...\nTell us what you thought about the event. What was the highlight for you? Was there anything that could be improved? Your feedback helps others decide which events to attend and assists organizers in making future events even better. Whether it’s the atmosphere, the music, the people, or the venue, let us know your thoughts! \nRemember to keep your review respectful and constructive – everyone reads these!"
    
    var body: some View {
        VStack(spacing: 0){
            ScrollView(){
                LazyVStack(alignment:.center, spacing: 30){
                    KFImage(URL(string: post.images[0]))
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
                    
                    if displayWarrning && rating == 0 {
                        WarningTextComponent(text: "Please select a rating!")
                    }
                    
                    VStack(alignment: .leading){
                        Text("Comment")
                            .font(.body)
                            .fontWeight(.bold)
                        TextField(placeholder, text: $description, axis: .vertical)
                            .lineLimit(15, reservesSpace: true)
                            .padding()
                            .background{Color("main-secondary-color")}
                            .cornerRadius(10)
                    }
                    .padding()
                    .frame(minWidth: UIScreen.main.bounds.width, alignment: .leading)
                    
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            
            VStack(){
                Divider()
                
                if rating > 0 {
                    NavigationLink(value: SelectionPath.rateParticipants(post: post, rating: .init(value: Double(rating), comment: description))) {
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
                } else {
                    HStack(spacing:2){
                        
                        Text("Next")
                            .fontWeight(.semibold)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.gray)
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .padding()
                    .onTapGesture {
                        displayWarrning.toggle()
                    }
                }
                
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
    EventReviewView(post: MockPost)
}
