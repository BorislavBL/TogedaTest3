//
//  User.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var profileImageUrl: [String]?
    var from: String?
    var fullname: String
    var description: String?
    let email: String
    var savedPosts: [String]
    let title: String?
    var friendIDs: [String]
    var eventIDs: [String]
    let abouts: [String]
    let interests: [String]
    var rating: Int
}

struct MiniUser: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var profileImageUrl: [String]?
    var from: String?
    var fullname: String
    let title: String?
}

struct Rating {
    let id: String
    let userId: String
    let comment: String?
    let rating: Int
}

let posts = Post.MOCK_POSTS

let userDescription = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen"
let mockAbouts = ["Designer", "ISFP", "Bachelor", "Single", "Non-smoker", "Drinks-often", "Workout-often"]
let mockInterests = ["hiking", "chess", "gym", "anime", "sushi", "movies", "working out"]
let events: [String] = []
let friends = ["1", "2", "3"]

extension User {
    static func findUser(byId id: String) -> User? {
        return MOCK_USERS.first(where: { $0.id == id })
    }
    
    static var MOCK_USERS: [User] = [
        .init(id: NSUUID().uuidString, username: "alison", profileImageUrl: ["person_1", "person_2", "person_3"], from: "United Kingdom, Leeds", fullname: "Alison Hogwards", description:userDescription, email: "brucethewain@gmail.com", savedPosts: [], title: "Graphic Designer", friendIDs: friends, eventIDs: events, abouts: mockAbouts, interests: mockInterests, rating: 90),
        .init(id: NSUUID().uuidString, username: "Emma", profileImageUrl: ["person_2"], from: "United Kingdom, Leeds", fullname: "Emma W", description:userDescription, email: "brucethewain@gmail.com", savedPosts: [], title: "Programmer", friendIDs: friends, eventIDs: events, abouts: mockAbouts, interests: mockInterests, rating: 90),
        .init(id: NSUUID().uuidString, username: "Batman3", profileImageUrl: ["person_3"], from: "United Kingdom, Leeds", fullname: "Bruce Wayne", description:userDescription, email: "brucethewain@gmail.com", savedPosts: [], title: "Founder", friendIDs: friends, eventIDs: events, abouts: mockAbouts, interests: mockInterests, rating: 90),
        .init(id: NSUUID().uuidString, username: "alison2", profileImageUrl: ["person_1"], from: "United Kingdom, Leeds", fullname: "Alison Hogwards2", description:userDescription, email: "brucethewain@gmail.com", savedPosts: [], title: "Mechanic", friendIDs: friends, eventIDs: events, abouts: mockAbouts, interests: mockInterests, rating: 90),
        .init(id: NSUUID().uuidString, username: "Batman5", profileImageUrl: ["person_3"], from: "United Kingdom, Leeds", fullname: "Bruce Wayne", description:userDescription, email: "brucethewain@gmail.com", savedPosts: [], title: nil, friendIDs: friends, eventIDs: events, abouts: mockAbouts, interests: mockInterests, rating: 90),
        .init(id: NSUUID().uuidString, username: "Emma2", profileImageUrl: ["person_2"], from: "United Kingdom, Leeds", fullname: "Emma L", description:userDescription, email: "brucethewain@gmail.com", savedPosts: [], title: "I just got here", friendIDs: friends, eventIDs: events, abouts: mockAbouts, interests: mockInterests, rating: 90)
    ]
}

extension MiniUser {
    static var MOCK_MINIUSERS: [MiniUser] = User.MOCK_USERS.map { user in
        return MiniUser(
            id: user.id,
            username: user.username,
            profileImageUrl: user.profileImageUrl,
            from: user.from,
            fullname: user.fullname,
            title: user.title
        )
    }
}

