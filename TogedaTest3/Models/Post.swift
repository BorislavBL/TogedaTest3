//
//  Post.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import SwiftUI

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let ownerId: String
    let title: String
    let imageUrl: [String]
    let description: String
    var peopleIn: [String]
    let maximumPeople: Int
    let location: PostLocation
    let date: Date
    let category: String
    let createdAt: Date
    var interests: [String]
    var user: MiniUser?
    let payment: Double
    var participants: [MiniUser]
    let type: String
    var accessability: Visabilities
    var rating: Double?
    var hasEnded: Bool
}


struct PostLocation: Hashable, Codable {
    let name: String
    let address: String?
    let city: String?
    let country: String?
    let latitude: Double
    let longitude: Double
}

let mockPostLocation = [
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.694954, longitude: 23.386198),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.633954, longitude: 23.381198),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.653954, longitude: 23.387198),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.624954, longitude: 23.397888),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.703154, longitude: 23.375558),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.633981, longitude: 23.333598),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.693154, longitude: 23.382298),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.664114, longitude: 23.405122),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.675134, longitude: 23.373128),
    PostLocation(name: "Sofia, Bulgaria", address: "st George Washington 41", city: "Sofia", country: "Bulgaria", latitude: 42.698234, longitude: 23.385778)
]

let postDescription = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen"

let users = MiniUser.MOCK_MINIUSERS

extension Post {
    static var MOCK_POSTS: [Post] = [
        .init(id: NSUUID().uuidString, ownerId: users[0].id, title: "Hiking in Vitosha Mountain - only cool people", imageUrl: ["event_1", "event_2", "event_3"], description: postDescription, peopleIn: [users[0].id, users[1].id, users[2].id, users[3].id], maximumPeople: 10, location: mockPostLocation[0], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[0], payment: 3.67, participants: [users[0], users[1], users[2], users[3]], type: "public", accessability: .Public, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[1].id, title: "Beach Volleyball", imageUrl: ["event_2", "event_1", "event_3"], description: postDescription, peopleIn: [users[1].id, users[5].id], maximumPeople: 10, location: mockPostLocation[1], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[1], payment: 0, participants: [users[1], users[2]], type: "public", accessability: .Public, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[2].id, title: "Skating at the hilton park", imageUrl: ["event_3", "event_2", "event_1"], description: postDescription, peopleIn: [users[2].id, users[4].id], maximumPeople: 10, location: mockPostLocation[2], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[2], payment: 3.76, participants: [users[1], users[3]], type: "private", accessability: .Public, rating: 4.5, hasEnded: true),
        .init(id: NSUUID().uuidString, ownerId: users[3].id, title: "Surfing at sunset", imageUrl: ["event_4", "event_2", "event_3"], description: postDescription, peopleIn: [users[3].id, users[4].id], maximumPeople: 10, location: mockPostLocation[3], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[3], payment: 8.56, participants: [users[3], users[2]], type: "public", accessability: .Ask_to_join, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[4].id, title: "Hiking in the Mountains", imageUrl: ["event_1", "event_2", "event_3"], description: postDescription, peopleIn: [users[4].id, users[1].id], maximumPeople: 10, location:mockPostLocation[4], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[4], payment: 0, participants: [users[4], users[0]], type: "private", accessability: .Ask_to_join, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[5].id, title: "Beach Volleybal near the restaurant", imageUrl: ["event_2", "event_4", "event_3"], description: postDescription, peopleIn: [users[5].id, users[1].id], maximumPeople: 10, location: mockPostLocation[5], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[5], payment: 0, participants: [users[5], users[2]], type: "public", accessability: .Public, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[0].id, title: "Surfing near the clifs", imageUrl: ["event_3", "event_2", "event_1"], description: postDescription, peopleIn: [users[0].id, users[3].id], maximumPeople: 10, location: mockPostLocation[6], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[0], payment: 2.00, participants: [users[0], users[4]], type: "public", accessability: .Ask_to_join, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[2].id, title: "Hiking in Vitosha Mountain", imageUrl: ["event_4", "event_2", "event_3"], description: postDescription, peopleIn: [users[2].id, users[5].id], maximumPeople: 10, location: mockPostLocation[7], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[2], payment: 0, participants: [users[2], users[1]], type: "private", accessability: .Public, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[4].id, title: "Sport activity at the beach", imageUrl: ["event_1", "event_2", "event_3"], description: postDescription, peopleIn: [users[4].id, users[2].id], maximumPeople: 10, location: mockPostLocation[8], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[4], payment: 0, participants: [users[4], users[3]], type: "secret", accessability: .Public, hasEnded: false),
        .init(id: NSUUID().uuidString, ownerId: users[3].id, title: "Skating with the boys", imageUrl: ["event_4", "event_2", "event_3"], description: postDescription, peopleIn: [users[3].id, users[2].id], maximumPeople: 10, location: mockPostLocation[9], date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[3], payment: 0, participants: [users[3], users[1]], type: "public", accessability: .Ask_to_join, rating: 4.5, hasEnded: true)
    ]
}
