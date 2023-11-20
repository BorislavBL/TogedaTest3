//
//  LinkPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.11.23.
//

import SwiftUI

struct LinkPreview: View {
    @StateObject var viewModel: LinkPreviewViewModel
    
    init(urlString: String) {
        self._viewModel = StateObject(wrappedValue: LinkPreviewViewModel(urlString: urlString))
    }
    
    var body: some View {
        VStack{
            if let metadata = viewModel.metadata {
                LPLinkViewRepresented(metadata: metadata)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 250)
            } else {
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width - 100, height: 250)
            }
        }
    }
}

#Preview {
    LinkPreview(urlString: "https://www.youtube.com/watch?v=Qg0PepGlxFs")
}

