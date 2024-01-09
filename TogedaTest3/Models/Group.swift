//
//  Group.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import Foundation

struct Club: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var imagesUrl: [String]
    var baseLocation: baseLocation
    var members: [ClubMember]
    var visability: Visabilities
    var askToJoin: Bool
    var category: String
    var description: String?
    var interests: [String]
    var eventIDs: [String]
    var memories: [String]
    var joinRequestUsers: [String]
    var permissions: Permissions
    
    var events: [Post]
}

struct ClubMember: Codable, Hashable {
    let userID: String
    var status: String
    
    var user: MiniUser
}

var mock_members: [ClubMember] = [
    ClubMember(userID: MiniUser.MOCK_MINIUSERS[0].id, status: "Admin", user: MiniUser.MOCK_MINIUSERS[0]),
    ClubMember(userID: MiniUser.MOCK_MINIUSERS[1].id, status: "Member", user: MiniUser.MOCK_MINIUSERS[1]),
    ClubMember(userID: MiniUser.MOCK_MINIUSERS[2].id, status: "Member", user: MiniUser.MOCK_MINIUSERS[2]),
    ClubMember(userID: MiniUser.MOCK_MINIUSERS[3].id, status: "Member", user: MiniUser.MOCK_MINIUSERS[3]),
    ClubMember(userID: MiniUser.MOCK_MINIUSERS[4].id, status: "Admin", user: MiniUser.MOCK_MINIUSERS[4])
]

let groupDescription = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen"

extension Club {
    static var MOCK_CLUBS: [Club] = [
        .init(id: NSUUID().uuidString, title: "Sky Diving Club Sofia", imagesUrl: ["event_1", "event_2"], baseLocation: mockLocation, members: mock_members, visability: .Public, askToJoin: false, category: "Sport", description: groupDescription, interests: mockInterests, eventIDs: [Post.MOCK_POSTS[0].id, Post.MOCK_POSTS[1].id], memories: ["event_1", "event_2", "event_3", "event_4"], joinRequestUsers: [Post.MOCK_POSTS[2].id], permissions: .All_members, events: [Post.MOCK_POSTS[0], Post.MOCK_POSTS[1]])
    ]
}
