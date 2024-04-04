//
//  User.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

struct EditUser: Codable, Hashable{
    var subToEmail: Bool
    var firstName: String
    var lastName: String
    var gender: String
    var birthDate: String
    var visibleGender: Bool
    var location: baseLocation
    var occupation: String
    var profilePhotos: [String]
    var interests: [Interest]

    var details: UserDetails
    
    static var example: EditUser = .init(subToEmail: false, firstName: "", lastName: "", gender: "", birthDate: "", visibleGender: false, location: mockLocation, occupation: "", profilePhotos: [], interests: [], details: mockUserDetails)
}

struct EditProfilePhoneNumber: Codable, Hashable {
    var phoneNumber: String
}

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
    var interests: [Interest]
}

struct User: Codable, Identifiable {
    var id: String
    var email: String
    var subToEmail: Bool
    var firstName: String
    var lastName: String
    var gender: String
    var birthDate: String
    var visibleGender: Bool
    var location: baseLocation
    var occupation: String
    var profilePhotos: [String]
    var interests: [Interest]
    var phoneNumber: String
    var verifiedPhone: Bool
    var verifiedEmail: Bool
    var createdDate: String
    var details: UserDetails
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

struct MiniUser: Identifiable, Codable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var birthDate: String
    var profilePhotos: [String]
    var occupation: String
    var location: baseLocation
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

//struct User: Identifiable, Codable, Hashable {
//    var id: String
//    var profileImageUrl: [String]
//    var firstName: String
//    var lastName: String
//    var bio: String?
//    var email: String
//    let phoneNumber: String
//    var birthDay: birthDay
//    var occipation: String
//    var baseLocation: baseLocation
//    var gender: String
//    let interests: [Interest]
//    var education: String?
//    var workout: String?
//    var personalityType: String?
//    var instagarm: String?
//    var savedPosts: [String]
//    var friendIDs: [String]
//    var createdEventIDs: [String]
//    var participatedEventIDs: [String]
//    var clubIDs: [String]
//    
//    var fullName: String {
//        return "\(firstName) \(lastName)"
//    }
//}

//// Interest structure
//struct Interest: Codable, Identifiable {
//    let id: Int
//    let name: String
//    let icon: String
//    let category: String
//}

// User details structure
struct UserDetails: Codable, Hashable {
    var id: String
    var bio: String?
    var education: String?
    var workout: String?
    var height: String?
    var personalityType: String?
    var instagram: String?
    var savedPostIds: [String]
    var friendIds: [String]
    var createdEventIds: [String]
    var participatedEventIds: [String]
    var clubIds: [String]
}

struct birthDay: Hashable, Codable{
    var date: String
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


//let mockTestInterests: [Interest] = [
//    .init(id: 1, name: "Lifting", icon: "🏋️‍♀️", category: "sport"),
//    .init(id: 2, name: "Fitness", icon: "👟", category: "sport"),
//    .init(id: 3, name: "Football", icon: "⚽️", category: "sport"),
//    .init(id: 4, name: "Basketball", icon: "🏀", category: "sport"),
//    .init(id: 5, name: "Voleyball", icon: "🏐", category: "sport"),
//    .init(id: 6, name: "Baseball", icon: "⚾️", category: "sport"),
//]
// UserDetails mock
let mockUserDetails = UserDetails(
    id: "user_details_id",
    bio: "Loves hiking and reading. Graphic designer by profession.",
    education: "Bachelor's in Graphic Design",
    workout: "Regular",
    height: "186",
    personalityType: "ISFP",
    instagram: "@userInstagram",
    savedPostIds: ["post1", "post2"],
    friendIds: ["friend1", "friend2"],
    createdEventIds: ["event1", "event2"],
    participatedEventIds: ["event3", "event4"],
    clubIds: ["club1", "club2"]
)


extension User {
    static func findUser(byId id: String) -> User? {
        return MOCK_USERS.first(where: { $0.id == id })
    }
    
    static var MOCK_USERS: [User] = [
        .init(
            id: UUID().uuidString,
            email: "brucethewain@gmail.com",
            subToEmail: true,
            firstName: "Alison",
            lastName: "Hogwards",
            gender: "Female",
            birthDate: "1990-01-01",
            visibleGender: true,
            location: mockLocation,
            occupation: "Designer",
            profilePhotos: ["person_1", "person_2", "person_3"],
            interests: mockInterests,
            phoneNumber: "359892206243",
            verifiedPhone: true,
            verifiedEmail: true,
            createdDate: "2024-02-07T17:53:46.034300Z",
            details: mockUserDetails
        ),
        .init(
            id: UUID().uuidString,
            email: "brucethewain@gmail.com",
            subToEmail: true,
            firstName: "Emma",
            lastName: "W",
            gender: "Female",
            birthDate: "1990-01-01",
            visibleGender: true,
            location: mockLocation,
            occupation: "Programmer",
            profilePhotos: ["person_2"],
            interests: mockInterests,
            phoneNumber: "359892206243",
            verifiedPhone: true,
            verifiedEmail: true,
            createdDate: "2024-02-07T17:53:46.034300Z",
            details: mockUserDetails
        ),
        .init(
            id: UUID().uuidString,
            email: "brucethewain@gmail.com",
            subToEmail: true,
            firstName: "Bruce",
            lastName: "Wayne",
            gender: "Male",
            birthDate: "1990-01-01",
            visibleGender: true,
            location: mockLocation,
            occupation: "Founder",
            profilePhotos: ["person_3"],
            interests: mockInterests,
            phoneNumber: "359892206243",
            verifiedPhone: true,
            verifiedEmail: true,
            createdDate: "2024-02-07T17:53:46.034300Z",
            details: mockUserDetails
        ),
        .init(
            id: UUID().uuidString,
            email: "brucethewain@gmail.com",
            subToEmail: true,
            firstName: "Alison",
            lastName: "Hogwards2",
            gender: "Female",
            birthDate: "1990-01-01",
            visibleGender: true,
            location: mockLocation,
            occupation: "Graphic Designer",
            profilePhotos: ["person_2", "person_3"],
            interests: mockInterests,
            phoneNumber: "359892206243",
            verifiedPhone: true,
            verifiedEmail: true,
            createdDate: "2024-02-07T17:53:46.034300Z",
            details: mockUserDetails
        ),
        .init(
            id: UUID().uuidString,
            email: "brucethewain@gmail.com",
            subToEmail: true,
            firstName: "B",
            lastName: "L",
            gender: "Male",
            birthDate: "1990-01-01",
            visibleGender: true,
            location: mockLocation,
            occupation: "Graphic Designer",
            profilePhotos: ["person_3"],
            interests: mockInterests,
            phoneNumber: "359892206243",
            verifiedPhone: true,
            verifiedEmail: true,
            createdDate: "2024-02-07T17:53:46.034300Z",
            details: mockUserDetails
        ),
        .init(
            id: UUID().uuidString,
            email: "brucethewain@gmail.com",
            subToEmail: true,
            firstName: "Emma",
            lastName: "L",
            gender: "Female",
            birthDate: "1990-01-01",
            visibleGender: true,
            location: mockLocation,
            occupation: "Graphic Designer",
            profilePhotos: ["person_1", "person_3"],
            interests: mockInterests,
            phoneNumber: "359892206243",
            verifiedPhone: true,
            verifiedEmail: true,
            createdDate: "2024-02-07T17:53:46.034300Z",
            details: mockUserDetails
        )
    ]
    
//    static var MOCK_USERS: [User] = [
//        .init(id: NSUUID().uuidString, profileImageUrl: ["person_1", "person_2", "person_3"], firstName: "Alison", lastName: "Hogwards", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: ["1"]),
//        .init(id: NSUUID().uuidString, profileImageUrl: ["person_2"], firstName: "Emma", lastName: "W", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Programmer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
//        .init(id: NSUUID().uuidString, profileImageUrl: ["person_3"], firstName: "Bruce", lastName: "Wayne", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Founder", baseLocation: mockLocation, gender: "Man", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ENTJ", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
//        .init(id: NSUUID().uuidString, profileImageUrl: ["person_2", "person_3"], firstName: "Alison", lastName: "Hogwards2", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
//        .init(id: NSUUID().uuidString, profileImageUrl: ["person_3"], firstName: "B", lastName: "L", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Man", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: []),
//        .init(id: NSUUID().uuidString, profileImageUrl: ["person_1", "person_3"], firstName: "Emma", lastName: "L", bio: userDescription, email: "brucethewain@gmail.com", phoneNumber: "+359 892206243", birthDay: mockBirthday, occipation: "Graphic Designer", baseLocation: mockLocation, gender: "Woman", interests: mockInterests, education: "Bachelor degree", workout: "Often", personalityType: "ISFP", instagarm: "@bgAlertTest", savedPosts: [], friendIDs: friends, createdEventIDs: events, participatedEventIDs: events, clubIDs: [])
//    ]
}





extension MiniUser {
    static var MOCK_MINIUSERS: [MiniUser] = User.MOCK_USERS.map { user in
        return MiniUser(id: user.id, firstName: user.firstName, lastName: user.lastName, birthDate: user.birthDate, profilePhotos: user.profilePhotos, occupation: user.occupation, location: user.location)
    }
}


