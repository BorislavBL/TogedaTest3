//
//  AccesabilityView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.09.23.
//

import SwiftUI

enum Visabilities: Hashable {
    case Public
    case Private
    case Ask_to_join
    
    var value : String {
      switch self {
      // Use Internationalization, as appropriate.
      case .Public: return "Public"
      case .Private: return "Private"
      case .Ask_to_join: return "Ask To Join"
      }
    }
}

struct AccesabilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedVisability: Visabilities
    
    var body: some View {
        List {
            Text("Accessability")
                .font(.title3)
                .fontWeight(.bold)
            
            Picker("", selection: $selectedVisability) {
                Text("Public").tag(Visabilities.Public)
                Text("Private").tag(Visabilities.Private)
                Text("Ask To Join").tag(Visabilities.Ask_to_join)
            }
            .labelsHidden()
            .pickerStyle(InlinePickerStyle())
            
            Group{
                if selectedVisability == .Public {
                    Text("Everyone will be able to join your event without any restrictions.")
                    
                } else if selectedVisability == .Private {
                    Text("Your event won't be visable on the feed page and people will be able to join it only if you personally invite them.")
                } else if selectedVisability == .Ask_to_join {
                    Text("Your event will be visable to evryone but people will have to request access in order to join.")
                }
            }
            .font(.callout)
            .foregroundColor(.gray)
        }
        .listStyle(.plain)
        .padding(.vertical)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        }
        )
        
        
    }
}


struct AccesabilityView_Previews: PreviewProvider {
    static var previews: some View {
        AccesabilityView(selectedVisability: .constant(.Public))
    }
}
