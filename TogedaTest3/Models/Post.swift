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
    let imageUrl: String
    let description: String
    var peopleIn: [String]
    let maximumPeople: Int
    let location: PostLocation
    let date: Date
    let category: String
    let createdAt: Date
    var interests: [String]
    var user: User?
    let payment: Double
    var participants: [User]
    let type: String
    var accessability: Visabilities
}


struct PostLocation: Hashable, Codable {
    let latitude: Double
    let longitude: Double
}

let postDescription = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen"

let users = User.MOCK_USERS

extension Post {
    static var MOCK_POSTS: [Post] = [
        .init(id: NSUUID().uuidString, ownerId: users[0].id, title: "Hiking in Vitosha Mountain - only cool people", imageUrl: "event_1", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.693954, longitude: 23.385198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[0], payment: 3.67, participants: [users[1], users[2]], type: "public", accessability: .Public),
        .init(id: NSUUID().uuidString, ownerId: users[1].id, title: "Beach Volleyball", imageUrl: "event_2", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.643954, longitude: 23.355198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[1], payment: 0, participants: [users[1], users[2]], type: "public", accessability: .Public),
        .init(id: NSUUID().uuidString, ownerId: users[2].id, title: "Skating at the hilton park", imageUrl: "event_3", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.633954, longitude: 23.386198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[2], payment: 3.76, participants: [users[1], users[2]], type: "private", accessability: .Public),
        .init(id: NSUUID().uuidString, ownerId: users[3].id, title: "Surfing at sunset", imageUrl: "event_4", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.723954, longitude: 23.385498), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[3], payment: 8.56, participants: [users[1], users[2]], type: "public", accessability: .Ask_to_join),
        .init(id: NSUUID().uuidString, ownerId: users[4].id, title: "Hiking in the Mountains", imageUrl: "event_1", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.688954, longitude: 23.385898), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[4], payment: 0, participants: [users[1], users[2]], type: "private", accessability: .Ask_to_join),
        .init(id: NSUUID().uuidString, ownerId: users[5].id, title: "Beach Volleybal near the restaurant", imageUrl: "event_2", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.643954, longitude: 23.375198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[5], payment: 0, participants: [users[1], users[2]], type: "public", accessability: .Public),
        .init(id: NSUUID().uuidString, ownerId: users[0].id, title: "Surfing near the clifs", imageUrl: "event_4", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.686954, longitude: 23.365198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[0], payment: 2.00, participants: [users[1], users[2]], type: "public", accessability: .Ask_to_join),
        .init(id: NSUUID().uuidString, ownerId: users[2].id, title: "Hiking in Vitosha Mountain", imageUrl: "event_1", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.689954, longitude: 23.389198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[2], payment: 0, participants: [users[1], users[2]], type: "private", accessability: .Public),
        .init(id: NSUUID().uuidString, ownerId: users[4].id, title: "Sport activity at the beach", imageUrl: "event_2", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.713954, longitude: 23.385198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[4], payment: 0, participants: [users[1], users[2]], type: "secret", accessability: .Public),
        .init(id: NSUUID().uuidString, ownerId: users[3].id, title: "Skating with the boys", imageUrl: "event_3", description: postDescription, peopleIn: [users[1].id, users[2].id], maximumPeople: 10, location: PostLocation(latitude: 42.6703954, longitude: 23.385198), date: Date(), category: "Sport", createdAt: Date(), interests: ["hiking", "outdoors", "activity", "social"], user: users[3], payment: 0, participants: [users[1], users[2]], type: "public", accessability: .Ask_to_join)
    ]
}
