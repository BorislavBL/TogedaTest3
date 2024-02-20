//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct TestView: View {
    @State var show: Bool = false
    @State var favoriteColor = 0
    
    var body: some View {
        VStack{
            Picker("What is your favorite color?", selection: $favoriteColor) {
                Text("Red").tag(0)
                Text("Green").tag(1)
                Text("Blue").tag(2)
            }
            .pickerStyle(.segmented)
        }
        .fullScreenCover(isPresented: /*@START_MENU_TOKEN@*/.constant(true)/*@END_MENU_TOKEN@*/, content: {
            NavigationStack{
                VStack{
                    Picker("What is your favorite color?", selection: $favoriteColor) {
                        Text("Red").tag(0)
                        Text("Green").tag(1)
                        Text("Blue").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
            }
        })
    }
    
  }



struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


//VStack(alignment: .leading, spacing: 20){
//    Button{
//        ceVM.showTimeSettings.toggle()
//    } label: {
//        HStack(alignment: .center, spacing: 10) {
//            Image(systemName: "calendar")
//                .imageScale(.large)
//            
//            
//            Text("Date & Time")
//            
//            Spacer()
//            
//            
//            Text(ceVM.isDate ? separateDateAndTime(from:ceVM.date).date : "Any day")
//                .foregroundColor(.gray)
//            
//            Image(systemName: ceVM.showTimeSettings ? "chevron.down" : "chevron.right")
//                .padding(.trailing, 10)
//                .foregroundColor(.gray)
//            
//        }
//        
//    }
//    
//    if ceVM.showTimeSettings {
//
//        
////                            if ceVM.timeSettings != 0 {
//        DatePicker("From", selection: $ceVM.from, displayedComponents: [.date, .hourAndMinute])
//            .fontWeight(.semibold)
//            
////                                if ceVM.timeSettings == 2 {
//        DatePicker("To", selection: $ceVM.to, displayedComponents: [.date, .hourAndMinute])
//                    .fontWeight(.semibold)
////                                }
////                            } else {
////                                HStack {
////                                    Text("The event won't have a specific timeframe.")
////                                        .fontWeight(.medium)
////                                        .padding()
////                                }
//        }
//        
//    
//}
//.createEventTabStyle()
