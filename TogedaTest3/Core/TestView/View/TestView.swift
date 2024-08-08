//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct TestView: View {
    
    @State var from = Date.now.addingTimeInterval(900)
    {
        didSet{
            if to < from.addingTimeInterval(599) {
                to = from.addingTimeInterval(600)
            }
        }
    }
    @State var to = Date.now.addingTimeInterval(4500)
    var body: some View {
        VStack{
            Menu{
                Button{print("flicking")} label: {
                    Text("Test menu")
                }
            } label:{
                Text("Test menu")
            }
            
            DatePicker("From", selection: $from, in: Date().addingTimeInterval(900)..., displayedComponents: [.date, .hourAndMinute])
                .fontWeight(.semibold)
            
            
            DatePicker("To", selection: $to, in: from.addingTimeInterval(600)..., displayedComponents: [.date, .hourAndMinute])
                .fontWeight(.semibold)
            
        }
    }
    
}



struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

