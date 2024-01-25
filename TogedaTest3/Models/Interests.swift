//
//  Interests.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.01.24.
//

import Foundation

struct Interest: Codable, Hashable {
    var name: String
    var icon: String
    var category: String
}

struct Category: Codable, Hashable {
    var name: String
    var icon: String
}

extension Category {
    static var Categories: [Category] = [
        .init(name: "Sport", icon: "🏃‍♂️"),
        .init(name: "Health", icon: "🌱"),
        .init(name: "Extreme", icon: "🔥"),
        .init(name: "Social", icon: "👥"),
        .init(name: "Business", icon: "🧑‍💼"),
        .init(name: "Entertainment", icon: "🎉"),
        .init(name: "Technologies", icon: "🚀"),
        .init(name: "Education", icon: "👨‍🎓"),
        .init(name: "Hobby", icon: "✨")
    ]
}

extension Interest {
    static var SportInterests: [Interest] = [
        .init(name: "Running", icon: "🏃‍♂️", category: "sport"),
        .init(name: "Cycling", icon: "🚴", category: "sport"),
        .init(name: "Swimming", icon: "🏊", category: "sport"),
        .init(name: "Workingout", icon: "💪", category: "sport"),
        .init(name: "Boxing", icon: "🥊", category: "sport"),
        .init(name: "Lifting", icon: "🏋️‍♀️", category: "sport"),
        .init(name: "Fitness", icon: "👟", category: "sport"),
        .init(name: "Football", icon: "⚽️", category: "sport"),
        .init(name: "Basketball", icon: "🏀", category: "sport"),
        .init(name: "Voleyball", icon: "🏐", category: "sport"),
        .init(name: "Baseball", icon: "⚾️", category: "sport"),
        .init(name: "Tennis", icon: "🎾", category: "sport"),
        .init(name: "Hockey", icon: "🏒", category: "sport"),
        .init(name: "Squash", icon: "⚫️", category: "sport"),
        .init(name: "Golf", icon: "🏌️", category: "sport"),
        .init(name: "Rugby", icon: "🏉", category: "sport"),
        .init(name: "Badmington", icon: "🏸", category: "sport"),
        .init(name: "Table tennis", icon: "🏓", category: "sport"),
        .init(name: "Skiing", icon: "⛷️", category: "sport"),
        .init(name: "Snowboarding", icon: "🏂", category: "sport"),
        .init(name: "Hiking", icon: "🏔️", category: "sport"),
        .init(name: "Climbing", icon: "🧗", category: "sport"),
        .init(name: "Martial arts", icon: "🥋", category: "sport"),
        .init(name: "Stretching", icon: "🙆‍♂️", category: "sport"),
        .init(name: "Pilates", icon: "🎽", category: "sport"),
        .init(name: "Skateboarding", icon: "🛹", category: "sport"),
        .init(name: "Dancing", icon: "💃", category: "sport"),
        .init(name: "Calisthenics", icon: "🤸", category: "sport"),
        .init(name: "Kayaking", icon: "🚣‍♂️", category: "sport"),
        .init(name: "Gymnastics", icon: "🤸‍♂️", category: "sport"),
        .init(name: "Handball", icon: "🤾", category: "sport"),
        .init(name: "Snorkeling", icon: "🤿", category: "sport"),
        .init(name: "Sailing", icon: "⛵️", category: "sport"),
    ]
    
    static var HealthInterests: [Interest] = [
        .init(name: "Yoga", icon: "🧘", category: "health"),
        .init(name: "Meditation", icon: "🧎‍♂️", category: "health"),
        .init(name: "Longevity", icon: "🌳", category: "health"),
        .init(name: "Skincare", icon: "🧴", category: "health"),
    ]
    
    static var ExtremeInterests: [Interest] = [
        .init(name: "Motocross", icon: "🏍️", category: "extreme"),
        .init(name: "Mountain biking", icon: "🚵", category: "extreme"),
        .init(name: "Scuba diving", icon: "🤿", category: "extreme"),
        .init(name: "Kite surfing", icon: "🪁", category: "extreme"),
        .init(name: "Windsurfing", icon: "🏄‍♂️", category: "extreme"),
        .init(name: "Rafting", icon: "🛶", category: "extreme"),
        .init(name: "Skydiving", icon: "🪂", category: "extreme"),
        .init(name: "Bungee jumping", icon: "🪢", category: "extreme"),
        .init(name: "Paintball", icon: "🔫", category: "extreme"),
        .init(name: "Airsoft", icon: "🫡", category: "extreme"),
        .init(name: "Downhill longboarding", icon: "🛹", category: "extreme"),
        .init(name: "Jet skiing", icon: "🚤", category: "extreme"),
        .init(name: "Paragliding", icon: "🪂", category: "extreme"),
        .init(name: "Hang gliding", icon: "🪂", category: "extreme"),
        .init(name: "Karting", icon: "🏎️", category: "extreme"),
    ]
    
    static var SocialInterests: [Interest] = [
        .init(name: "Party", icon: "🎉", category: "social"),
        .init(name: "Board games", icon: "🎲", category: "social"),
        .init(name: "Gaming", icon: "🎮", category: "social"),
        .init(name: "Escape room", icon: "🧩", category: "social"),
        .init(name: "Card games", icon: "♠️", category: "social"),
        .init(name: "Networking", icon: "🗣️", category: "social"),
        .init(name: "Events", icon: "📆", category: "social"),
        .init(name: "Drinks", icon: "🍻", category: "social"),
        .init(name: "Drinks & chat", icon: "🍹", category: "social"),
        .init(name: "Hanging out", icon: "👫", category: "social"),
        .init(name: "Restaurants", icon: "🍽️", category: "social"),
        .init(name: "Shopping", icon: "🛍️", category: "social"),
        .init(name: "Chess", icon: "♟️", category: "social"),
        .init(name: "Picnic", icon: "🧺", category: "social"),
        .init(name: "Outdoor", icon: "🥏", category: "social"),
        .init(name: "Beach", icon: "🏖️", category: "social"),
        .init(name: "Walking in nature", icon: "🌄", category: "social"),
        .init(name: "Hanging in the park", icon: "🏞️", category: "social"),
        .init(name: "Dog walking", icon: "🦮", category: "social"),
        .init(name: "Camping", icon: "🏕️", category: "social"),
    ]
    
    static var BusinessInterests: [Interest] = [
        .init(name: "Startups", icon: "🦄", category: "business"),
        .init(name: "Finance & investment", icon: "🤑", category: "business"),
        .init(name: "Crypto & NFT", icon: "🔐", category: "business"),
        .init(name: "Polotics", icon: "🏦", category: "business"),
        .init(name: "Entrepreneurship", icon: "🚀", category: "business"),
        .init(name: "Marketing", icon: "📈", category: "business"),
    ]
    
    static var EntertainmentInterests: [Interest] = [
        .init(name: "Cinema", icon: "🍿", category: "entertainment"),
        .init(name: "Theatre", icon: "🎭", category: "entertainment"),
        .init(name: "Clubbing", icon: "🪩", category: "entertainment"),
        .init(name: "Concerts", icon: "🎶", category: "entertainment"),
        .init(name: "Festivals", icon: "🎊", category: "entertainment"),
        .init(name: "Stand up", icon: "🎙️", category: "entertainment"),
        .init(name: "Karaoke", icon: "🎤", category: "entertainment"),
        .init(name: "Museums & galleries", icon: "🏛️", category: "entertainment"),
        .init(name: "Acting", icon: "🎬", category: "entertainment"),
        .init(name: "Fashion", icon: "🥼", category: "entertainment"),
        .init(name: "Anime", icon: "😼", category: "entertainment"),
        .init(name: "Movies & series", icon: "📼", category: "entertainment"),
        .init(name: "Arts", icon: "🖼️", category: "entertainment"),
    ]
    
    static var TechnologiesInterests: [Interest] = [
        .init(name: "Engineering", icon: "💡", category: "technology"),
        .init(name: "Programming", icon: "👨‍💻", category: "technology"),
        .init(name: "VR & AR", icon: "🥽", category: "technology"),
        .init(name: "Technology", icon: "📱", category: "technology"),
        .init(name: "Robotics", icon: "🤖", category: "technology"),
    ]
    
    static var EducationInterests: [Interest] = [
        .init(name: "Science", icon: "🧪", category: "education"),
        .init(name: "Psychology", icon: "🫥", category: "education"),
        .init(name: "Phylosophy", icon: "🤔", category: "education"),
        .init(name: "Astronomy", icon: "🔭", category: "education"),
        .init(name: "Math", icon: "🥸", category: "education"),
        .init(name: "Physics", icon: "👨‍🏫", category: "education"),
        .init(name: "University", icon: "👨‍🎓", category: "education"),
        .init(name: "Biology", icon: "🧬", category: "education"),
        .init(name: "Chemistry", icon: "⚗️", category: "education"),
        .init(name: "Languages", icon: "👅", category: "education"),
    ]
    
    static var HobbyInterests: [Interest] = [
        .init(name: "Self-improvement", icon: "🗿", category: "hobby"),
        .init(name: "Reading", icon: "🤓", category: "hobby"),
        .init(name: "Darts", icon: "🎯", category: "hobby"),
        .init(name: "Billiards", icon: "🎱", category: "hobby"),
        .init(name: "Bowling", icon: "🎳", category: "hobby"),
        .init(name: "Music", icon: "🎶", category: "hobby"),
        .init(name: "Painting", icon: "🎨", category: "hobby"),
        .init(name: "Cooking", icon: "👨‍🍳", category: "hobby"),
        .init(name: "Cars", icon: "🚗", category: "hobby"),
        .init(name: "Podcasts", icon: "💬", category: "hobby"),
        .init(name: "Singing", icon: "🎵", category: "hobby"),
        .init(name: "Ecology", icon: "🌱", category: "hobby"),
        .init(name: "Religion", icon: "🙏", category: "hobby"),
        .init(name: "Design", icon: "⚜️", category: "hobby"),
        .init(name: "Writing", icon: "✍️", category: "hobby"),
        .init(name: "Journaling", icon: "📕", category: "hobby"),
        .init(name: "Self-care", icon: "💆‍♀️", category: "hobby"),
        .init(name: "Digital art", icon: "🖌️", category: "hobby"),
        .init(name: "Fishing", icon: "🎣", category: "hobby"),
        .init(name: "Hunting", icon: "🐗", category: "hobby"),
    ]
}
