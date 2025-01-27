//
//  DescriptionView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 17.09.23.
//

import SwiftUI

struct DescriptionView: View {
    @Binding var description: String
    @Environment(\.dismiss) private var dismiss
    @State private var showWarning = false
    @FocusState private var isFocused: Bool

    var placeholder: String
    let characterLimit = 5000

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                    }

                    TextField("", text: $description, axis: .vertical)
                        .focused($isFocused)
                        .onChange(of: description) { newValue in
                            if newValue.count > characterLimit {
                                description = String(newValue.prefix(characterLimit))
                            }
                        }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .scrollDismissesKeyboard(.interactively)
        .swipeBack()
        .onAppear {
            isFocused = true
        }
        .navigationTitle("Description")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .imageScale(.medium)
                    .padding(.all, 8)
                    .background(Color("main-secondary-color"))
                    .clipShape(Circle())
            },
            trailing: Text("\(description.count)/\(characterLimit)")
                .foregroundColor(description.count > characterLimit ? .red : .gray)
                .font(.footnote)
        )
    }
}


struct DescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionView(description: .constant(""), placeholder: "Describe the purpose of your event. What activities are you planning? Mention any special guests who might be attending. Will there be food and drinks? Help attendees know what to expect.")
    }
}
