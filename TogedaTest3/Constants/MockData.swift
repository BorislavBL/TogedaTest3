//
//  MockData.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.05.24.
//

import Foundation


let MockUser: Components.Schemas.UserInfoDto = .init(
    id: "c3c42802-90f1-7073-03e6-5e761d648d24",
    email: "borkolorinkov@gmail.com",
    subToEmail: true,
    firstName: "Borislav",
    lastName: "Lorinkov",
    gender: .MALE,
    birthDate: "2000-07-11",
    visibleGender: true,
    location: .init(name: "Sofia, Bulgaria", address: nil, city: "Sofia", state: "Sofia", country: "Bulgaria", latitude: 42.6889525, longitude: 23.3188913),
    occupation: "Mechanic",
    profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    interests: [
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport")
    ],
    phoneNumber: "359892206243",
    verifiedPhone: false,
    verifiedEmail: true,
    details: .init(
        id: "1",
        bio: "Never back down never what?",
        education: "Bachelors",
        workout: "Often",
        personalityType: "INFP",
        instagram: "@Foncho",
        referralCode: "fonchoooo"
    ),
    participatedPostsCount: 3,
    friendsCount: 3,
    currentFriendshipStatus: nil
)


let MockMiniUser = Components.Schemas.MiniUser(
    id: "12345678",
    firstName: "Emily",
    lastName: "Hogwards",
    profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg", "https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    occupation: "Mechanic",
    location: Components.Schemas.BaseLocation.init(
        name: "Sofia, Bulgaria",
        address:"Something",
        city: "Sofia",
        country: "Bulgaria",
        latitude: 42.6977,
        longitude: 23.3219
    ), 
    birthDate: "2000-07-11"
)

let MockBasicUserInfo = Components.Schemas.UserDto(
    subToEmail: true,
    firstName: "Borko",
    lastName: "Lorinkov",
    gender: Components.Schemas.UserDto.genderPayload.MALE,
    birthDate: Date(), // Fallback to current date if parsing fails
    visibleGender: true,
    occupation: "Party Animal",
    profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg", "https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    interests: [
        Components.Schemas.Interest.init(name: "InterestName", icon: "0xe52a", category: "MyCategory"),
        Components.Schemas.Interest.init(name: "InterestName2", icon: "0xe52b", category: "MyCategory1"),
        Components.Schemas.Interest.init(name: "InterestName3", icon: "0xe52a", category: "MyCategory2"),
        Components.Schemas.Interest.init(name: "InterestName4", icon: "0xe52a", category: "MyCategory3"),
        Components.Schemas.Interest.init(name: "InterestName5", icon: "0xe52a", category: "MyCategory4"),
        Components.Schemas.Interest.init(name: "InterestName6", icon: "0xe52a", category: "MyCategory5")
    ],
    phoneNumber: "359885230163",
    location: Components.Schemas.BaseLocation.init(
        name: "Sofia, Bulgaria",
        address:"Something",
        city: "Sofia",
        country: "Bulgaria",
        latitude: 42.6977,
        longitude: 23.3219
    )
)

let MockCreatePost = Components.Schemas.CreatePostDto(
    title: "Test Post",
    images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    description: "Hello friends wellcome to my event> Todays topic slavery.",
    maximumPeople: 10,
    location: Components.Schemas.BaseLocation.init(
        name: "Sofia, Bulgaria",
        address:"Something",
        city: "Sofia",
        country: "Bulgaria",
        latitude: 42.6977,
        longitude: 23.3219
    ),
    interests: [
        Components.Schemas.Interest.init(name: "InterestName", icon: "0xe52a", category: "MyCategory"),
        Components.Schemas.Interest.init(name: "InterestName2", icon: "0xe52b", category: "MyCategory1"),
        Components.Schemas.Interest.init(name: "InterestName3", icon: "0xe52a", category: "MyCategory2"),
        Components.Schemas.Interest.init(name: "InterestName4", icon: "0xe52a", category: "MyCategory3"),
        Components.Schemas.Interest.init(name: "InterestName5", icon: "0xe52a", category: "MyCategory4"),
        Components.Schemas.Interest.init(name: "InterestName6", icon: "0xe52a", category: "MyCategory5")
    ],
    payment: 0,
    accessibility: .PUBLIC,
    askToJoin: false,
    inClubID: nil,
    fromDate: Date().addingTimeInterval(15 * 60),
    toDate: nil, needsLocationalConfirmation: false)


let MockExtendedMiniUSer = Components.Schemas.ExtendedMiniUser(user: MockMiniUser, _type: .CO_HOST, locationStatus: .NONE)

let MockMiniPost: Components.Schemas.MiniPostDto = .init(
    id: NSUUID().uuidString,
    title: "Test title",
    images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"], owner:  .init(
    id: "1234567890",
    firstName: "Borko",
    lastName: "Lorinkov",
    profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    occupation: "Mechanic",
    location:  Components.Schemas.BaseLocation.init(
        name: "Sofia, Bulgaria",
        address:"Something",
        city: "Sofia",
        country: "Bulgaria",
        latitude: 42.6977,
        longitude: 23.3219
    ),
    birthDate: "2000-07-11"
), currentUserStatus: .NOT_PARTICIPATING, 
    currentUserRole: .NORMAL,
    status: .HAS_STARTED)

let MockPost = Components.Schemas.PostResponseDto(
    id: "1234567890",
    title: "Hiking in Vitosha Mountain",
    images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    description: "Hello friends wellcome to my event> Todays topic slavery.",
    maximumPeople: 10,
    location: Components.Schemas.BaseLocation.init(
        name: "Sofia, Bulgaria",
        address:"Something",
        city: "Sofia",
        country: "Bulgaria",
        latitude: 42.6977,
        longitude: 23.3219
    ),
    toDate: Date(),
    fromDate: nil,
    createdAt: Date(),
    interests: [
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport")
    ],
    owner: .init(
        id: "1234567890",
        firstName: "Borko",
        lastName: "Lorinkov",
        profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
        occupation: "Mechanic",
        location:  Components.Schemas.BaseLocation.init(
            name: "Sofia, Bulgaria",
            address:"Something",
            city: "Sofia",
            country: "Bulgaria",
            latitude: 42.6977,
            longitude: 23.3219
        ), 
        birthDate: "2000-07-11"
    ),
    payment: 0, 
    currentUserStatus: .NOT_PARTICIPATING,
    accessibility: .PUBLIC,
    askToJoin: false,
    needsLocationalConfirmation: false, 
    rating: nil,
    clubId: nil,
    participantsCount: 5,
    status: .NOT_STARTED,
    savedByCurrentUser: true
)


let MockMiniClub: Components.Schemas.MiniClubDto = .init(
    id: NSUUID().uuidString,
    owner: MockMiniUser,
    title: "Sky Diving Club",
    images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    currentUserStatus: .PARTICIPATING,
    currentUserRole: .MEMBER)

let MockClub = Components.Schemas.ClubDto(
    id: "2131", 
    owner: MockMiniUser,
    title: "Sky Diving Club",
    images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"],
    description: "Minchagata Minchagata v snejna zima v leten den krasiv si vinagi debel.", location: Components.Schemas.BaseLocation.init(
        name: "Sofia, Bulgaria",
        address:"Something",
        city: "Sofia",
        country: "Bulgaria",
        latitude: 42.6977,
        longitude: 23.3219
    ),
    accessibility: .PUBLIC,
    askToJoin: false, 
    currentUserStatus: .PARTICIPATING,
    interests: [
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport")
    ],
    memories: [],
    currentUserRole: .MEMBER, 
    membersCount: 0, 
    previewMembers: [MockMiniUser],
    permissions: .ADMINS_ONLY,
    createdAt: Date())



let mockAlertBodyFriendRequestReceived: Components.Schemas.AlertBodyFriendRequestReceived = .init(sender: MockMiniUser, alertBodyTypeAsString: "Aleeee alee aleee aleee")

let mockAlertBodyReviewEndedPost: Components.Schemas.AlertBodyReviewEndedPost = .init(post: MockMiniPost, alertBodyTypeAsString: "Aleeee alee aleee aleee")

let mockAlertBodyReceivedJoinRequest: Components.Schemas.AlertBodyReceivedJoinRequest = .init(post: MockMiniPost, club: nil, fromUser: MockMiniUser, forType: .POST, alertBodyTypeAsString: "Aleeee alee aleee aleee")

let mockAlertBodyAcceptedJoinRequest: Components.Schemas.AlertBodyAcceptedJoinRequest = .init(post: MockMiniPost, club: nil, acceptedUser: MockMiniUser, forType: .POST, alertBodyTypeAsString: "Aleeee alee aleee aleee")
let mockAlertBodyPostHasStartedRequest: Components.Schemas.AlertBodyPostHasStarted = .init(post: MockMiniPost, alertBodyTypeAsString: "Aaaaaaaaaaaa")

//let mockMessage: Components.Schemas.ChatMessage = .init(id: "", chatId: "", sender: MockBaseUser, content: "Hey how are you?", contentType: .NORMAL, createdAt: Date())

let mockReceivedMessage: Components.Schemas.ReceivedChatMessageDto = .init(id: "", chatId: "", sender: MockMiniUser, content: "Hey how are you?", contentType: .NORMAL, createdAt: Date())

let mockChatRoom: Components.Schemas.ChatRoomDto = .init(id: UUID().uuidString, _type: .FRIENDS, post: nil, club: nil, latestMessage: mockReceivedMessage, previewMembers: [MockMiniUser], read: true, latestMessageTimestamp: Date())

//let MockBaseUser: Components.Schemas.User = .init(id: NSUUID().uuidString, email: "borkolorinkov@gmail.com", subToEmail: true, firstName: "Borko", lastName: "lorinkov", gender: .MALE, birthDate: "2000-07-12", visibleGender: true, location: Components.Schemas.BaseLocation.init(
//    name: "Sofia, Bulgaria",
//    address:"Something",
//    city: "Sofia",
//    country: "Bulgaria",
//    latitude: 42.6977,
//    longitude: 23.3219
//), occupation: "Mechanic", profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"], interests: [], phoneNumber: "", verifiedPhone: false, verifiedEmail: true, savedPosts: [], status: .ONLINE)
