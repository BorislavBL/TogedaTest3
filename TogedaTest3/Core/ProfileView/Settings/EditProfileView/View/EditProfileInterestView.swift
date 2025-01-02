//
//  EditProfileInterestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.12.23.
//

import SwiftUI
import WrappingHStack

struct EditProfileInterestView: View {
    @Binding var selectedInterests: [Interest]
    
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
                    
                    if selectedInterests.count < 5 && displayError {
                        WarningTextComponent(text: "Select at least 5 interests.")
                            .padding(.bottom, 15)
                    } else if displayError && selectedInterests.count > 20 {
                        WarningTextComponent(text: "You can not select more than 20 interests.")
                            .padding(.bottom, 15)
                    }
                    
                    if sport.count > 0 || health.count > 0 {
                        Text("Sport & Health")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    }
                    
                    InterestCategorySection(interests: sport + health, selectedInterests: $selectedInterests, color: .green)
                    
                    if social.count > 0 || business.count > 0 {
                        Text("Social & Business")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: social + business, selectedInterests: $selectedInterests, color: .cyan)
                    
                    if entertainment.count > 0 {
                        Text("Entertainment")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: entertainment, selectedInterests: $selectedInterests, color: .orange)
                    
                    if technology.count > 0 || education.count > 0 {
                        Text("Technology & Education")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: technology + education, selectedInterests: $selectedInterests, color: .blue)
                    
                    if hobby.count > 0 {
                        Text("Hobby")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    }
                    InterestCategorySection(interests: hobby, selectedInterests: $selectedInterests, color: .purple)
                    
                    if extreme.count > 0 {
                        Text("Extreme")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    InterestCategorySection(interests: extreme, selectedInterests: $selectedInterests, color: .red)
                    
                    
                }
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
        }
        .swipeBack()
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
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        }
            .disableWithOpacity(selectedInterests.count < 5 || selectedInterests.count > 20)
            .onTapGesture {
                if selectedInterests.count < 5 || selectedInterests.count > 20 {
                    displayError.toggle()
                }
            }
        )
    }
    
}

#Preview {
    EditProfileInterestView(selectedInterests: .constant(Interest.BusinessInterests))
}
