//
//  MockData.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.05.24.
//

import Foundation


let MockUser: Components.Schemas.User = .init(
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
    profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/8BAF0323-68E4-4F19-B88C-8BAF86EEF0D2.jpeg"],
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
        savedPostIds: [],
        friendIds: [],
        createdEventIds: [],
        participatedEventIds: [],
        clubIds: []
    )
)

let MockMiniUser = Components.Schemas.MiniUser(
    id: "12345678",
    firstName: "Emily",
    lastName: "Hogwards",
    profilePhotos: ["https://www.example.com/photo1.jpg", "https://www.example.com/photo2.jpg"],
    occupation: "Mechanic",
    location: Components.Schemas.BaseLocation.init(
        name: "Sofia, Bulgaria",
        address:"Something",
        city: "Sofia",
        country: "Bulgaria",
        latitude: 42.6977,
        longitude: 23.3219
    )
)

let MockBasicUserInfo = Components.Schemas.UserDto(
    subToEmail: true,
    firstName: "Borko",
    lastName: "Lorinkov",
    gender: Components.Schemas.UserDto.genderPayload.MALE,
    birthDate: Date(), // Fallback to current date if parsing fails
    visibleGender: true,
    occupation: "Party Animal",
    profilePhotos: ["https://www.example.com/photo1.jpg", "https://www.example.com/photo2.jpg"],
    interests: [
        Components.Schemas.InterestDto.init(name: "InterestName", icon: "0xe52a", category: "MyCategory"),
        Components.Schemas.InterestDto.init(name: "InterestName2", icon: "0xe52b", category: "MyCategory1"),
        Components.Schemas.InterestDto.init(name: "InterestName3", icon: "0xe52a", category: "MyCategory2"),
        Components.Schemas.InterestDto.init(name: "InterestName4", icon: "0xe52a", category: "MyCategory3"),
        Components.Schemas.InterestDto.init(name: "InterestName5", icon: "0xe52a", category: "MyCategory4"),
        Components.Schemas.InterestDto.init(name: "InterestName6", icon: "0xe52a", category: "MyCategory5")
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
    images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/A840DC1D-9D40-4A55-A453-212570A7019F.jpeg"],
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
    toDate: nil)


let MockPost = Components.Schemas.PostResponseDto(
    id: "1234567890",
    title: "Hiking in Vitosha Mountain",
    images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/8BAF0323-68E4-4F19-B88C-8BAF86EEF0D2.jpeg"],
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
        profilePhotos: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/8BAF0323-68E4-4F19-B88C-8BAF86EEF0D2.jpeg"],
        occupation: "Mechanic",
        location:  Components.Schemas.BaseLocation.init(
            name: "Sofia, Bulgaria",
            address:"Something",
            city: "Sofia",
            country: "Bulgaria",
            latitude: 42.6977,
            longitude: 23.3219
        )
    ),
    payment: 0, 
    currentUserStatus: .NOT_PARTICIPATING,
    accessibility: .PUBLIC,
    askToJoin: false,
    rating: nil,
    hasEnded: false, 
    club: nil, 
    participantsCount: 5
)
