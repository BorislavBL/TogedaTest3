//
//  DateView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 17.09.23.
//

import SwiftUI

struct DateView: View {
    @Binding var isDate: Bool
    @Binding var date: Date
    @Binding var from: Date
    @Binding var to: Date
    @Environment(\.dismiss) private var dismiss
    
    @Binding var daySettings: Int
    @Binding var timeSettings: Int
    
    var body: some View {
        ScrollView{
            VStack(alignment:.leading){
                
                Text("Choose Date")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Picker("Choose Day", selection: $daySettings) {
                    Text("Exact day").tag(0)
                    Text("Any day").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                
                DatePicker("Choose date", selection: $date, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .disabled(!isDate)
                    .padding(.horizontal, 8)
                    .accentColor(.blue)
                    .onChange(of: daySettings) { oldValue, newValue in
                        if newValue == 1 {
                            isDate = false
                        } else {
                            isDate = true
                        }
                    }
//                    .frame(width: 320, height: 320)


                if isDate {
                    Text("Choose Time")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Picker("Choose Time", selection: $timeSettings) {
                        Text("Anytime").tag(0)
                        Text("Exact Time").tag(1)
                        Text("Range").tag(2)
                        
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if timeSettings != 0 {
                        DatePicker("From", selection: $from, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .padding(.horizontal)
                            .fontWeight(.semibold)
                        
                        if timeSettings == 2 {
                            DatePicker("To", selection: $to, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.graphical)
                                .padding(.horizontal)
                                .fontWeight(.semibold)
                        }
                    } else {
                        HStack {
                            Text("The event won't have a specific timeframe.")
                                .fontWeight(.medium)
                                .padding()
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxHeight: UIScreen.main.bounds.height, alignment: .top)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
        }
            
        )
        .navigationTitle("Date")
        .navigationBarTitleDisplayMode(.inline)

    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(isDate:.constant(true), date: .constant(Date()), from: .constant(Date()), to: .constant(Date()), daySettings: .constant(0), timeSettings: .constant(0) )
    }
}
