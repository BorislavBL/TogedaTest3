//
//  InstagramOverlay.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.09.24.
//

import SwiftUI

struct InstagramOverlay: View {
    @Binding var isActive: Bool
    @State var step = 1
    var post: Components.Schemas.PostResponseDto
    var body: some View {
        ZStack{
            Color(.black).opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isActive = false
                    }
                }
            
            let content = InstagramStoryView(post: post)
            
            VStack(spacing: 20){
                if step == 1 {
                    Text("Before you open Instagram COPY the events link!")
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    Button{
                        UIPasteboard.general.string = createURLLink(postID: post.id, clubID: nil, userID: nil)
                        withAnimation {
                            step = 2
                        }
                    } label:{
                        Text("Copy")
                            .font(.subheadline)
                            .foregroundStyle(Color("base"))
                            .fontWeight(.semibold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .background{Color("blackAndWhite")}
                            .cornerRadius(10)
                    }
                } else if step == 2 {
                    Text("Add the LINK sticker to your Story.")
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    Image("instaStory_1")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    
                    Button{
                        withAnimation {
                            step = 3
                        }
                    } label:{
                        Text("Next")
                            .font(.subheadline)
                            .foregroundStyle(Color("base"))
                            .fontWeight(.semibold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .background{Color("blackAndWhite")}
                            .cornerRadius(10)
                        
                    }
                } else if step == 3 {
                    Text("Select the link sticker")
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    Image("instaStory_2")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    
                    Button{
                        withAnimation {
                            step = 4
                        }
                    } label:{
                        Text("Next")
                            .font(.subheadline)
                            .foregroundStyle(Color("base"))
                            .fontWeight(.semibold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .background{Color("blackAndWhite")}
                            .cornerRadius(10)
                        
                    }
                } else if step == 4 {
                    Text("Paste the link you copied here.")
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    Image("instaStory_3")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    
                    Button{
                        withAnimation {
                            step = 5
                        }
                    } label:{
                        Text("Next")
                            .font(.subheadline)
                            .foregroundStyle(Color("base"))
                            .fontWeight(.semibold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .background{Color("blackAndWhite")}
                            .cornerRadius(10)
                        
                    }
                } else if step == 5 {
                    Text("Place the LINK sticker over placeholder.")
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    Image("instaStory_Final")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    
                    VStack(spacing: 5){
                        Button{
                            UIPasteboard.general.string = createURLLink(postID: post.id, clubID: nil, userID: nil)
                        } label:{
                            Text("Copy Link")
                                .font(.subheadline)
                                .foregroundStyle(Color("blackAndWhite"))
                                .fontWeight(.semibold)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 13)
                                .background{Color("blackAndWhite").opacity(0.2)}
                                .cornerRadius(10)
                        }
                        
                        Button{
                            UIPasteboard.general.string = createURLLink(postID: post.id, clubID: nil, userID: nil)
                            
                            isActive = false
                            
                            takeSnapshot(of: content) { image in
                                if let img = image {
                                    shareToInstagram(backgroundImage: img, appID: "togeda.net")
                                }
                            }
                        } label:{
                            Text("Open Instagram")
                                .font(.subheadline)
                                .foregroundStyle(Color("base"))
                                .fontWeight(.semibold)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 13)
                                .background{Color("blackAndWhite")}
                                .cornerRadius(10)
                            
                        }
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
    
    private func takeSnapshot<Content: View>(of content: Content, completion: @escaping (UIImage?) -> Void) {
        // Use the SnapshotView to capture the content
        let snapshotView = SnapshotView(content: {
            content
        }) { image in
            completion(image)  // Return the image using the completion handler
        }
        
        // Trigger the snapshot by temporarily presenting the SnapshotView
        let window = UIApplication.shared.windows.first!
        let snapshotContainer = UIHostingController(rootView: snapshotView)
        window.rootViewController?.present(snapshotContainer, animated: false, completion: nil)
        
        // Dismiss the SnapshotView after capturing the snapshot
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            snapshotContainer.dismiss(animated: false, completion: nil)
        }
    }
    
    func canOpenInstagram() -> Bool {
        let url = URL(string: "instagram-stories://share")!
        return UIApplication.shared.canOpenURL(url)
    }

    func shareToInstagram(backgroundImage: UIImage, appID: String) {
        guard let imageData = backgroundImage.pngData() else { return }

        let urlScheme = URL(string: "instagram-stories://share?source_application=\(appID)")!

        if UIApplication.shared.canOpenURL(urlScheme) {
            // Prepare the pasteboard item with the image data
            let pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.backgroundImage": imageData
            ]
            UIPasteboard.general.setItems([pasteboardItems], options: [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ])

            // Open Instagram
            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
        } else {
            // Instagram is not installed
            print("Instagram is not installed")
        }
    }

}

#Preview {
    InstagramOverlay(isActive: .constant(false), post: MockPost)
}
