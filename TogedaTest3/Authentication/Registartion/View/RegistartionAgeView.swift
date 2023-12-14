//
//  RegistartionAgeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI

struct RegistartionAgeView: View {
    enum FocusedField: Hashable{
        case day,month,year
    }
    
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focus: FocusedField?
    @Environment(\.dismiss) var dismiss
    @State var day: String = ""
    @State var month: String = ""
    @State var year: String = ""
    @State private var displayError: Bool = false
    var body: some View {
        VStack {
            Text("What's your birthday?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            HStack{
                TextField("", text: $day)
                    .placeholder(when: day.isEmpty) {
                        Text("DD")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .bold()
                    .focused($focus, equals: .day)
                    .onChange(of: day) {
                        if day.count >= 2 {
                            day = String(day.prefix(2))
                            focus = .month
                        }
                    }
                
                Text("/")
                
                TextField("", text: $month)
                    .placeholder(when: month.isEmpty) {
                        Text("MM")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .bold()
                    .focused($focus, equals: .month)
                    .onChange(of: month) {
                        if month.count >= 2 {
                            month = String(month.prefix(2))
                            focus = .year
                        }
                    }
                
                Text("/")
                
                TextField("", text: $year)
                    .placeholder(when: year.isEmpty) {
                        Text("YYYY")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .bold()
                    .focused($focus, equals: .year)
                    .onChange(of: year) {
                        if year.count >= 4 {
                            year = String(year.prefix(4))
                        }
                    }

            }
            .padding(10)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 2)
            .padding(.bottom, 15)
            
            if displayError {
                WarningTextComponent(text: "Just write your birthday, if it's conviniet for you?")
                    .padding(.bottom, 15)
            }
            
            Text("Your age will be visable to others")
                .bold()
                .foregroundStyle(.gray)
            
            Spacer()
            
            NavigationLink(destination: RegistrationEmailView()){
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(!validDate(day: day, month: month, year: year))
            .onTapGesture {
                if !validDate(day: day, month: month, year: year){
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .padding(.horizontal)
        
        .onTapGesture {
            hideKeyboard()
        }
        .ignoresSafeArea(.keyboard)
        .padding(.vertical)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
    }
    
    func validDate(day: String, month: String, year: String) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if dateFormatter.date(from:"\(year)-\(month)-\(day)") != nil && day.count == 2 && month.count == 2 && year.count == 4 {
            return true
        }
        else {
           return false
        }
    }
    
    var foregroundColor: Color {
        if colorScheme == .dark {
            return Color(.white)
        } else {
            return Color(.black)
        }
    }
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray5)
        } else {
            return Color(.systemGray6)
        }
    }
}

#Preview {
    RegistartionAgeView()
}
