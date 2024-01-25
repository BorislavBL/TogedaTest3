//
//  OptionsSheet.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.01.24.
//

import SwiftUI

struct OptionsSheet: View {
    var saveAction: () -> Void
    var shareLink: URL
    var reportAction: () -> Void
    
    var body: some View {
        List {
            Button("Save") {
               saveAction()
            }
            
            ShareLink(item: shareLink!) {
                Text("Share via")
            }
            
            Button("Report") {
                reportAction
            }
            
            if let user = postsViewModel.posts[postsViewModel.clickedPostIndex].user, user.id == userId {
                Button("Delete") {
                    postsViewModel.selectedOption = "Delete"
                }
            }
        }
        .presentationDetents([.fraction(0.25)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    OptionsSheet()
}
