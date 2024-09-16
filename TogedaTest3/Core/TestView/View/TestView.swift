//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import UIKit
import Kingfisher

struct TestView: View {
    var post = MockPost
    @State var screenshot: UIImage? = nil

    var body: some View {
        ZStack{
            let content = InstagramStoryView(post: post)
            
            VStack{
                Text("123")

                
                if canOpenInstagram() {
                    Text("Yes it can")
                } else {
                    Text("Yes it can")
                }
                
                Button(action: {
                    takeSnapshot(of: content) { image in
                        if let img = image {
                            shareToInstagram(backgroundImage: img, appID: "togeda.net")
                        }
                    }

                }) {
                    Text("Share to Instagram Story")
                }
            }
        }
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






struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

