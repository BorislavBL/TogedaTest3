//
//  FilterOptions.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

let timeStrings = ["Starting soon", "1h", "2h", "3h", "Today", "Tomorrow", "This week", "This month", "Any", "Choose a time"]
let categoryStrings = ["Sport", "Adventure", "Educational", "Social", "Casual", "Indoor", "Outdoor", "Grand", "Any"]
let distanceStrings = ["100m", "500m", "1km", "3km", "5km", "10km", "100km", "Any Distance", "Choose a distance", "Any"]
let typeStrings = ["Trending", "Newest", "Oldest", "Friends", "Any"]
let interestStrings = [
    "Hiking",
    "Self-Development",
    "Sushi",
    "Photography",
    "Traveling",
    "Music",
    "Gaming",
    "Reading",
    "Cooking",
    "Yoga",
    "Art",
    "Fitness",
    "Fishing",
    "Craft Beer",
    "Coffee",
    "Wine Tasting",
    "Meditation",
    "Volunteering",
    "Gardening",
    "Knitting",
    "Podcasts",
    "Animals",
    "Camping",
    "Dancing",
    "Painting",
    "Fashion",
    "DIY Projects",
    "Sports",
    "Movies",
    "Stand-up Comedy",
    "Baking",
    "Shopping",
    "Skiing",
    "Surfing",
    "Board Games",
    "Politics",
    "Writing",
    "Astrology",
    "Tech Gadgets",
    "Theatre",
    "Skateboarding",
    "Kite Surfing",
    "Sustainability",
    "Spirituality",
    "Tea",
    "Museums",
    "Investing",
    "Martial Arts",
    "Swimming",
    "Retro Games",
    "Animation",
    "Minimalism",
    "Foodie Adventures",
    "Concerts",
    "Cycling",
    "Philosophy",
    "Puzzles",
    "Bird Watching",
    "Veganism",
    "Rock Climbing",
    "Pet Care",
    "Calligraphy",
    "Aquariums",
    "Digital Art",
    "Festivals",
    "Golf",
    "Renewable Energy",
    "Running",
    "Scuba Diving",
    "Video Editing",
    "Cosplay",
    "Horror Movies",
    "Creative Writing",
    "Stargazing",
    "Musicals",
    "Blogging"
]

let TimeOptions = timeStrings.map { Option(id: NSUUID().uuidString, name: $0) }
let CategoryOptions = categoryStrings.map { Option(id: NSUUID().uuidString, name: $0) }
let DistanceOptions = distanceStrings.map { Option(id: NSUUID().uuidString, name: $0) }
let TypeOptions = typeStrings.map { Option(id: NSUUID().uuidString, name: $0) }
let InterestOptions = interestStrings.map { Option(id: NSUUID().uuidString, name: $0) }
