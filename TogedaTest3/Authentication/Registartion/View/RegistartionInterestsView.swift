//
//  RegistartionInterestsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.12.23.
//

import SwiftUI
import WrappingHStack

struct RegistartionInterestsView: View {
    @ObservedObject var vm: RegistrationViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State var sport: [Interest] = Interest.SportInterests
    @State var extreme: [Interest] = Interest.ExtremeInterests
    @State var social: [Interest] = Interest.SocialInterests
    @State var hobby: [Interest] = Interest.HobbyInterests
    
    @State var business: [Interest] = Interest.BusinessInterests
    @State var education: [Interest] = Interest.EducationInterests
    @State var entertainment: [Interest] = Interest.EntertainmentInterests
    @State var health: [Interest] = Interest.HealthInterests
    @State var technology: [Interest] = Interest.TechnologiesInterests
    
    @Environment(\.colorScheme) var colorScheme
    @State private var displayError: Bool = false
    
    @State private var searchText: String = ""
    @State private var cancelSearch: Bool = false
    
    var body: some View {
        VStack {
            ScrollView{
                LazyVStack(alignment: .center, spacing: 20) {
                    if !cancelSearch {
                        Text("What are your interested about?")
                            .multilineTextAlignment(.center)
                            .font(.title).bold()
                            .padding(.top, 20)
                    }
                    
                    CustomSearchBar(searchText: $searchText, showCancelButton: $cancelSearch)
                    
                    if displayError {
                        WarningTextComponent(text: "Select at least 5 interests.")
                            .padding(.bottom, 15)
                    }
                    
                    if sport.count > 0 || health.count > 0 {
                        Text("Sport & Health")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    }
                    
                    InterestCategorySection(interests: sport + health, selectedInterests: $vm.selectedInterests, color: .green)
                    
                    if social.count > 0 || business.count > 0 {
                        Text("Social & Business")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: social + business, selectedInterests: $vm.selectedInterests, color: .cyan)
                    
                    if entertainment.count > 0 {
                        Text("Entertainment")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: entertainment, selectedInterests: $vm.selectedInterests, color: .orange)
                    
                    if technology.count > 0 || education.count > 0 {
                        Text("Technology & Education")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: technology + education, selectedInterests: $vm.selectedInterests, color: .blue)
                    
                    if hobby.count > 0 {
                        Text("Hobby")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    }
                    InterestCategorySection(interests: hobby, selectedInterests: $vm.selectedInterests, color: .purple)
                    
                    if extreme.count > 0 {
                        Text("Extreme")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: extreme, selectedInterests: $vm.selectedInterests, color: .red)
                    
                    
                }
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            NavigationLink(destination: RegistrationNumberView(vm: vm)){
                Text("Next (\(vm.selectedInterests.count)/5)")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.selectedInterests.count < 5)
            .onTapGesture {
                if vm.selectedInterests.count < 5 {
                    displayError.toggle()
                }
            }
        }
        .onChange(of: searchText){
            if !searchText.isEmpty {
                sport = Interest.SportInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                extreme = Interest.ExtremeInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                social = Interest.SocialInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                hobby = Interest.HobbyInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                health = Interest.HealthInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                business = Interest.BusinessInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                entertainment = Interest.EntertainmentInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                technology = Interest.TechnologiesInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
                education = Interest.EducationInterests.filter{ result in
                    result.name.lowercased().contains(searchText.lowercased())
                }
            } else {
                sport = Interest.SportInterests
                extreme = Interest.ExtremeInterests
                hobby = Interest.HobbyInterests
                social = Interest.SocialInterests
                health = Interest.HealthInterests
                business = Interest.BusinessInterests
                entertainment = Interest.EntertainmentInterests
                technology = Interest.TechnologiesInterests
                education = Interest.EducationInterests
            }
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
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

struct InterestCategorySection: View {
    var interests: [Interest]
    @Binding var selectedInterests: [Interest]
    var color: Color
    
    var body: some View {
        WrappingHStack(alignment: .leading){
            ForEach(interests, id: \.name) { interest in
                Button {
                    if selectedInterests.contains(where:{ interest.name == $0.name}) {
                        selectedInterests.removeAll { $0.name == interest.name}
                    } else {
                        
                        selectedInterests.append(interest)
                        
                    }
                } label: {
                    if selectedInterests.contains(where:{ interest.name == $0.name}) {
                        Text("\(interest.icon) \(interest.name)")
                            .foregroundColor(.white)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(height: 16)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background{Capsule().fill(Color(color).opacity(0.8))}
                    } else {
                        Text("\(interest.icon) \(interest.name)")
                            .foregroundColor(Color("textColor"))
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(height: 16)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background{Capsule().fill(Color(color).opacity(0.3))}
                    }
                }
            }
        }
    }
}

#Preview {
    RegistartionInterestsView(vm: RegistrationViewModel())
}
