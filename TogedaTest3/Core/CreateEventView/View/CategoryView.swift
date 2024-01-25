//
//  CategoryView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.09.23.
//

import SwiftUI
import WrappingHStack

struct CategoryView: View {
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
    
    @State private var searchText: String = ""
    @State private var cancelSearch: Bool = false
    
    var text: String
    var minInterests: Int
    
    var body: some View {
        VStack {
            ScrollView{
                
                LazyVStack(alignment: .leading, spacing: 20) {
                    CustomSearchBar(searchText: $searchText, showCancelButton: $cancelSearch)
                        .padding(.top, 20)
                    
                    if !cancelSearch {
                        Text(text)
                            .font(.body)
                            .foregroundStyle(.gray)
                            
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
        .disableWithOpacity(selectedInterests.count < minInterests)
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(selectedInterests: .constant([]), text: "Select at least one tag related to your event", minInterests: 0)
    }
}
