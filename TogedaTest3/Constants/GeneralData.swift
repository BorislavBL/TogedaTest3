//
//  GeneralData.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.06.24.
//

import Foundation

let CROPPING_HEIGHT = 1000
let CROPPING_WIDTH = 600

let workout: [String] = ["Everyday", "Most days", "Often", "Sometimes", "Never"]
let education: [String] = ["Bachelor degree", "Master degree", "PhD", "At Uni", "High school"]
let personalityType: [String] = [
    "ISTJ", "ISFJ", "INFJ", "INTJ",
    "ISTP", "ISFP", "INFP", "INTP",
    "ESTP", "ESFP", "ENFP", "ENTP",
    "ESTJ", "ESFJ", "ENFJ", "ENTJ"
]

let directMarketingAgreement = try! AttributedString(markdown: "[Direct Marketing Agreement](\(TogedaLinks().directMarketingAgreement))")

struct TogedaLinks {
    let privacyPolicy: String = "https://docs.google.com/document/d/1oRpJoIQubBcoijDzwCbFjZ7miOjf9su_85TAnATsK2I/edit?usp=sharing"
    let termsOfUse: String = "https://docs.google.com/document/d/16SNvY5euyNNG-T2rWSSz2TpNaMl47Cth0OAvQ5pTpb4/edit?usp=sharing"
    let paidActivitiesAgreement: String = "https://docs.google.com/document/d/15RDF8zxYI8bB71eK94MU64zlg5XNn4T0fQfcNKYn0mc/edit?usp=sharing"
    let directMarketingAgreement: String = "https://docs.google.com/document/d/1tN3NsCXIetenGJTRmf_2ffzJ8n65WV5flUuBSgtD4QY/edit?usp=sharing"
    
    let website: String  = "https://www.togeda.net/"
    let instagram: String  = "https://www.instagram.com/togeda_net/"
    let discord: String  = "https://discord.gg/mn6xcgF3BP"
    let appstore: String = "https://apps.apple.com/us/app/togeda-friends-activities/id6737203832"
}

enum APIEnvironment {
    case production
    case test
}

struct TogedaMainLinks {
    static let environment: APIEnvironment = .production // Change this to .test to switch environments

    private static let productionBaseURL = "https://api.togeda.net"
    private static let testBaseURL = "http://test-env-11.eba-mjv4k9hc.eu-central-1.elasticbeanstalk.com"

    static var baseURL: String {
        return environment == .production ? productionBaseURL : testBaseURL
    }

    static var websocketURL: String {
        return environment == .production ? "wss://api.togeda.net/ws" : "ws://test-env-11.eba-mjv4k9hc.eu-central-1.elasticbeanstalk.com/ws"
    }
}
