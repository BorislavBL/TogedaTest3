//
//  DateView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 17.09.23.
//

import SwiftUI

struct DateView: View {
    @State var date = Date()
    @State var from = Date()
    @State var to = Date()
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeSettings = 0
    
    var body: some View {
        ScrollView{
            VStack(alignment:.leading){
                Text("Choose Date")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                DatePicker("Choose date", selection: $date, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.horizontal, 8)
                    .accentColor(.blue)
//                    .frame(width: 320, height: 320)


                
                Text("Choose Time")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Picker("Choose Time", selection: $timeSettings) {
                    Text("Exact Time").tag(0)
                    Text("Range").tag(1)
                    Text("Anytime").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if timeSettings != 2 {
                    DatePicker("From", selection: $from, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                        .fontWeight(.semibold)
                    
                    if timeSettings == 1 {
                        DatePicker("To", selection: $to, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .padding(.horizontal)
                            .fontWeight(.semibold)
                    }
                } else {
                    Text("Anytime")
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .frame(maxHeight: UIScreen.main.bounds.height, alignment: .top)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        }
        )
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView()
    }
}
