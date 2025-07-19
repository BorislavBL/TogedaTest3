//
//  StringHelpers.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import Foundation

func formatBigNumbers(_ num: Int) -> String {
    let number = Double(num)
    
    switch number {
    case 1_000_000_000...:
        return String(format: "%.1fB", number / 1_000_000_000)
    case 1_000_000...:
        return String(format: "%.1fM", number / 1_000_000)
    case 1_000...:
        return String(format: "%.1fK", number / 1_000)
    default:
        return "\(num)"
    }
}

func interestsOrder(_ interests: [Interest]) -> String {
    var text = ""
    for i in interests.indices {
        if i < 3 {
            text += "\(interests[i].icon) \(interests[i].name) "
        }
    }
    
    return text
}

func interestsOrder1(_ interests: [Components.Schemas.Interest]) -> String {
    var text = ""
    for i in interests.indices {
        if i < 3 {
            text += "\(interests[i].icon) \(interests[i].name) "
        }
    }
    
    return text
}


func locationCityAndCountry(_ location: Components.Schemas.BaseLocation) -> String {
    var locationComponents = [String]()
    
    if let city = location.city {
        if let state = location.state {
            if city != state {
                locationComponents.append(city)
                locationComponents.append(state)
            } else {
                locationComponents.append(city)
            }
        } else {
            locationComponents.append(city)
        }
    } else if let state = location.state {
        locationComponents.append(state)
    }
    
    if let country = location.country {
        locationComponents.append(country)
    }
    
    return locationComponents.joined(separator: ", ")
}

func locationAddress(_ location: Components.Schemas.BaseLocation) -> String {
    var locationComponents = [String]()
    
    if let street = location.address {
        locationComponents.append(street)
    }
    
    var cityAndState = ""
    if let city = location.city {
        if let state = location.state {
            if city != state {
                cityAndState = "\(city), \(state)"
            } else {
                cityAndState = city
            }
        } else {
            cityAndState = city
        }
    } else if let state = location.state {
        cityAndState = state
    }
    
    if !cityAndState.isEmpty {
        locationComponents.append(cityAndState)
    }
    
    if let country = location.country {
        locationComponents.append(country)
    }
    
    return locationComponents.joined(separator: ", ")
}


func convertCmToFeetAndInches(_ centimeters: String) -> String? {
    guard let cm = Double(centimeters) else { return nil }
    
    let totalInches = cm / 2.54
    let feet = Int(totalInches / 12)
    let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
    
    return "\(feet)' \(inches)\""
}

func createURLLink(postID: String?, clubID: String?, userID: String?) -> String{
    let baseURL = "https://api.togeda.net/in-app/"
    var url = baseURL
    if let id = postID {
        url += "event?id=\(id)"
    } else if let id = clubID {
        url += "club?id=\(id)"
    } else if let id = userID {
        url += "user?id=\(id)"
    } else {
        url += "app"
    }
    
    return url
}

// Helper function to truncate text to a maximum of 20 characters
func truncatedText(_ text: String, maxLength: Int) -> String {
    if text.count > maxLength {
        let index = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..<index]) + "..."
    } else {
        return text
    }
}

func trimAndLimitWhitespace(_ text: String) -> String {
    // Step 1: Trim leading and trailing whitespace and newlines
    var trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Step 2: Check if the resulting text is empty (only whitespace originally)
    if trimmedText.isEmpty {
        return ""
    }
    
    // Step 3: Replace occurrences of more than three consecutive newlines with three newlines
    // This regex matches four or more consecutive newline characters
    let excessiveNewlinesPattern = "\n{4,}"
    let regex = try? NSRegularExpression(pattern: excessiveNewlinesPattern, options: [])
    
    // Replace matches of the pattern with exactly three newlines
    trimmedText = regex?.stringByReplacingMatches(in: trimmedText, options: [], range: NSRange(location: 0, length: trimmedText.utf16.count), withTemplate: "\n\n\n") ?? trimmedText

    return trimmedText
}

//func formatURLsInText(in text: String) -> String {
//    // Define the regular expression pattern for URLs
//    let pattern = "(https?://[a-zA-Z0-9./?=_-]+)"
//    
//    // Create the regular expression object
//    let regex = try! NSRegularExpression(pattern: pattern, options: [])
//    
//    // Perform the regex search on the input text
//    let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
//    
//    // Start building the formatted string
//    var formattedText = text
//    
//    // Loop through each match (starting from the last to prevent index shifting)
//    for match in matches.reversed() {
//        if let urlRange = Range(match.range, in: text) {
//            let url = String(text[urlRange])
//            
//            // Extract domain name for display
//            if let domain = URL(string: url)?.host {
//                let formattedURL = "[link](\(url))"
//                formattedText.replaceSubrange(urlRange, with: formattedURL)
//            }
//        }
//    }
//    
//    return formattedText
//}

/// Returns `true` when `text`
///   • contains **only** emoji grapheme clusters, and
///   • has **fewer than 10** of them.
/// The check is Unicode-aware, so complex emojis like “👩🏻‍💻” count as one.
func isEmojiOnly(_ text: String) -> Bool {
    // Get rid of leading/trailing white-space & newlines.
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false }

    var clusterCount = 0

    for char in trimmed {               // Iterates over full grapheme clusters.
        // A cluster qualifies as an emoji if *any* scalar inside it wants
        // emoji presentation (covers plain & variant-selector cases).
        let isEmoji = char.unicodeScalars.contains {
            $0.properties.isEmojiPresentation || $0.properties.isEmoji
        }
        if !isEmoji { return false }    // Found a non-emoji → fail fast.

        clusterCount += 1
        if clusterCount >= 13 { return false } // Too many → bail out early.
    }

    return true                         // All clusters were emoji and < 10 total.
}
