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
        VStack{
            Text("123")
            InstagramStoryView(screenshot: $screenshot)
                .frame(width: 0, height: 0)
                .opacity(0)
            
            Button(action: {
                if let image = screenshot {
                    shareToInstagram(backgroundImage: image, appID: "togeda.net")
                }
            }) {
                Text("Share to Instagram Story")
            }
            .disabled(screenshot == nil)
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

