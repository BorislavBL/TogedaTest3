//
//  UserRequestComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.05.24.
//

import SwiftUI
import Kingfisher

struct UserRequestComponent: View {
    private let size: ImageSize = .medium
    var user: Components.Schemas.MiniUser
    var confirm: () -> ()
    var delete: () -> ()
    
    var body: some View {
        NavigationLink(value: SelectionPath.profile(user)){
            HStack(alignment:.top){
                KFImage(URL(string: user.profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                
            }
            VStack(alignment:.leading){
                Text("\(user.firstName) \(user.lastName)")
                    .font(.footnote)
                    .fontWeight(.semibold)
                
                
                HStack(alignment:.center, spacing: 10) {
                    Button {
                        confirm()
                    } label: {
                        Text("Confirm")
                            .normalTagTextStyle()
                            .frame(maxWidth: .infinity)
                            .normalTagRectangleStyle()
                    }
                    Button {
                        delete()
                    } label: {
                        Text("Delete")
                            .normalTagTextStyle()
                            .frame(maxWidth: .infinity)
                            .normalTagRectangleStyle()
                    }
                }
            }
            .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    UserRequestComponent(user: MockMiniUser, confirm: {}, delete: {})
}
