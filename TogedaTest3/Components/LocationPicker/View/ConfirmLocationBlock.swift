//
//  ConfirmLocationBlock.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.05.24.
//

import SwiftUI

struct ConfirmLocationBlock: View {
    var name: String?
    var locality: String?
    var reset: () -> ()
    var action: () -> ()
    
    var body: some View {
        VStack{
            Text("Select Location")
                .font(.title2.bold())
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .overlay{
                    HStack{
                        Spacer()
                        Button(action: {
                            reset()
                        }, label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.white, .gray)
                        })

                    }
                }

            
            HStack(spacing: 15){
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 6) {
                    if let name = self.name, !name.isEmpty {
                        Text(name)
                            .font(.title3.bold())
                    } else {
                        Text("No Name")
                            .font(.title3.bold())
                    }
                    
                    if let locality = self.locality, !locality.isEmpty {
                        Text(locality)
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("No Locality")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding(.vertical,5)
            
            Button {
                action()
            } label: {
                Text("Confirm")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical,12)
                    .background{
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.blue)
                    }
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.bar)
                .ignoresSafeArea()
        }
        .frame(maxHeight: .infinity,alignment: .bottom)
    }
}

#Preview {
    ConfirmLocationBlock(reset: {}, action: {})
}
