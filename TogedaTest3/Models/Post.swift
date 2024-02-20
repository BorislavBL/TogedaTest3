//
//  Post.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import SwiftUI

struct CreatePost: Codable {
    var title: String
    var images: [String]
    var description: String?
    var maximumPeople: Int?
    var location: baseLocation
    var fromDate: String?
    var toDate: String?
    var interests: [Interest]
    var payment: Double
    var accessibility: String
    var askToJoin: Bool
    var inClubID: String?
}


struct Post: Identifiable, Codable, Hashable {
    let id: String
    let ownerId: String
    let title: String
    let imageUrl: [String]
    let description: String?
    var peopleIn: [String]
    var joinRequests: [String]
    let maximumPeople: Int?
    let location: baseLocation
    let date: Date
    let createdAt: Date
    var interests: [Interest]
    var user: MiniUser?
    let payment: Double
    var participants: [MiniUser]
    var accessability: String
    var askToJoin: Bool
    var rating: Double?
    var hasEnded: Bool
    var inClubID: String?
}


let mockPostLocation: [baseLocation] = [
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.607442, longitude: 23.250461),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.625011, longitude: 23.350787),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.653954, longitude: 23.387198),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.672200, longitude: 23.307418),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.709127, longitude: 23.3037966),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.633981, longitude: 23.333598),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.742127, longitude: 23.298799),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.736892, longitude: 23.359391),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.675134, longitude: 23.373128),
    .init(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.700187, longitude: 23.290698)
]

let postDescription = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen"

let users = MiniUser.MOCK_MINIUSERS

extension Post {
    static var MOCK_POSTS: [Post] = [
        .init(id: NSUUID().uuidString, ownerId: users[1].id, title: "Hiking in Vitosha Mountain", imageUrl: ["event_1", "event_2", "event_3"], description: postDescription, peopleIn: [users[0].id, users[1].id, users[2].id, users[3].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[0], date: Date(), createdAt: Date(), interests: mockInterests, user: users[1], payment: 3.67, participants: [users[0], users[1], users[2], users[3]], accessability: "PUBLIC", askToJoin: false, hasEnded: false, inClubID: nil),
        .init(id: NSUUID().uuidString, ownerId: users[0].id, title: "Kart racing", imageUrl: ["event_2", "event_1", "event_3"], description: postDescription, peopleIn: [users[0].id, users[5].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[1], date: Date(), createdAt: Date(), interests: mockInterests, user: users[0], payment: 0, participants: [users[1], users[2]], accessability: "PUBLIC", askToJoin: false, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[2].id, title: "Football", imageUrl: ["event_3", "event_2", "event_1"], description: postDescription, peopleIn: [users[2].id, users[4].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[2], date: Date(), createdAt: Date(), interests: mockInterests, user: users[2], payment: 3.76, participants: [users[1], users[3]], accessability: "PUBLIC", askToJoin: false, rating: 4.5, hasEnded: true, inClubID: NSUUID().uuidString),
        .init(id: NSUUID().uuidString, ownerId: users[3].id, title: "Let's play table tennis", imageUrl: ["event_4", "event_2", "event_3"], description: postDescription, peopleIn: [users[3].id, users[4].id], joinRequests: ["1","2"], maximumPeople: 10, location: mockPostLocation[3], date: Date(), createdAt: Date(), interests: mockInterests, user: users[3], payment: 8.56, participants: [users[3], users[2]], accessability: "PUBLIC", askToJoin: true, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[4].id, title: "Escape Room - the Prison", imageUrl: ["event_1", "event_2", "event_3"], description: postDescription, peopleIn: [users[4].id, users[1].id], joinRequests: ["1"], maximumPeople: 10, location:mockPostLocation[4], date: Date(), createdAt: Date(), interests: mockInterests, user: users[4], payment: 0, participants: [users[4], users[0]], accessability: "PUBLIC", askToJoin: true, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[5].id, title: "My Project X", imageUrl: ["event_2", "event_4", "event_3"], description: postDescription, peopleIn: [users[5].id, users[1].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[5], date: Date(), createdAt: Date(), interests: mockInterests, user: users[5], payment: 0, participants: [users[5], users[2]], accessability: "PUBLIC", askToJoin: false, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[0].id, title: "Running race in the park", imageUrl: ["event_3", "event_2", "event_1"], description: postDescription, peopleIn: [users[0].id, users[3].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[6], date: Date(), createdAt: Date(), interests: mockInterests, user: users[0], payment: 2.00, participants: [users[0], users[4]], accessability: "PUBLIC", askToJoin: true, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[2].id, title: "Chess Tournament - The Last One Standing", imageUrl: ["event_4", "event_2", "event_3"], description: postDescription, peopleIn: [users[2].id, users[5].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[7], date: Date(), createdAt: Date(), interests: mockInterests, user: users[2], payment: 0, participants: [users[2], users[1]], accessability: "PUBLIC", askToJoin: false, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[4].id, title: "Sport activities", imageUrl: ["event_1", "event_2", "event_3"], description: postDescription, peopleIn: [users[4].id, users[2].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[8], date: Date(), createdAt: Date(), interests: mockInterests, user: users[4], payment: 0, participants: [users[4], users[3]], accessability: "PUBLIC", askToJoin: false, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[3].id, title: "Playing Cards", imageUrl: ["event_4", "event_2", "event_3"], description: postDescription, peopleIn: [users[3].id, users[2].id], joinRequests: [], maximumPeople: 10, location: mockPostLocation[9], date: Date(), createdAt: Date(), interests: mockInterests, user: users[3], payment: 0, participants: [users[3], users[1]], accessability: "PUBLIC", askToJoin: true, rating: 4.5, hasEnded: true)
    ]
}
