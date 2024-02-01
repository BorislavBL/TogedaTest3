//
//  User.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

struct CreateUser: Codable, Hashable {
    var profilePhotos: [String]
    var firstName: String
    var lastName: String
    var email: String
    var subToEmail: Bool
    var password: String
    var phoneNumber: String
    var birthDate: String
    var occupation: String
    var location: baseLocation?
    var gender: String
    var visibleGender: Bool
    var interests: [String]
}

struct User: Identifiable, Codable, Hashable {
    var id: String
    var profileImageUrl: [String]
    var firstName: String
    var lastName: String
    var bio: String?
    var email: String
    let phoneNumber: String
    var birthDay: birthDay
    var occipation: String
    var baseLocation: baseLocation
    var gender: String
    let interests: [Interest]
    var education: String?
    var workout: String?
    var personalityType: String?
    var instagarm: String?
    var savedPosts: [String]
    var friendIDs: [String]
    var createdEventIDs: [String]
    var participatedEventIDs: [String]
    var clubIDs: [String]
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

struct birthDay: Hashable, Codable{
    var date: String
}

struct MiniUser: Identifiable, Codable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var profileImageUrl: [String]
    var occupation: String
    var baseLocation: baseLocation
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

let posts = Post.MOCK_POSTS

let userDescription = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen"
let mockAbouts = ["Designer", "ISFP", "Bachelor", "Single", "Non-smoker", "Drinks-often", "Workout-often"]
let mockInterests: [Interest] = [
    .init(name: "Lifting", icon: "🏋️‍♀️", category: "sport"),
    .init(name: "Fitness", icon: "👟", category: "sport"),
    .init(name: "Football", icon: "⚽️", category: "sport"),
    .init(name: "Basketball", icon: "🏀", category: "sport"),
    .init(name: "Voleyball", icon: "🏐", category: "sport"),
    .init(name: "Baseball", icon: "⚾️", category: "sport"),
]
let events: [String] = []
let friends = ["1", "2", "3"]
let mockBirthday = birthDay(date: "2000-07-12")
let mockLocation = baseLocation(name: "Sofia, Bulgaria", address: nil, city: "Sofia", state: nil, country: "Bulgaria", latitude: 42.697175, longitude: 23.322826)



extension User {
    static func findUser(byId id: String) -> User? {
        return MOCK_USERS.first(where: { $0.id == id })
    }
    
    static var MOCK_USERS: [User] = [
        .init(id: NSUUID().uuidString, profileImageUrl: ["person_1", "person_2", "person_3"], firstName: "Alison", lastName: "Hogwards", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: ["1"]),
        .init(id: NSUUID().uuidString, profileImageUrl: ["person_2"], firstName: "Emma", lastName: "W", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Programmer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
        .init(id: NSUUID().uuidString, profileImageUrl: ["person_3"], firstName: "Bruce", lastName: "Wayne", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Founder", baseLocation: mockLocation, gender: "Man", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ENTJ", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
        .init(id: NSUUID().uuidString, profileImageUrl: ["person_2", "person_3"], firstName: "Alison", lastName: "Hogwards2", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
        .init(id: NSUUID().uuidString, profileImageUrl: ["person_3"], firstName: "B", lastName: "L", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Man", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
        .init(id: NSUUID().uuidString, profileImageUrl: ["person_1", "person_3"], firstName: "Emma", lastName: "L", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: [])
    ]
}


extension MiniUser {
    static var MOCK_MINIUSERS: [MiniUser] = User.MOCK_USERS.map { user in
        return MiniUser(id: user.id, firstName: user.firstName, lastName: user.lastName, profileImageUrl: user.profileImageUrl, occupation: user.occipation, baseLocation: user.baseLocation)
    }
}


