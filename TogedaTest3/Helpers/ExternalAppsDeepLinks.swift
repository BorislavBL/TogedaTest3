//
//  ExternalAppsDeepLinks.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.10.24.
//

import SwiftUI

// Google Calendar
func isGoogleCalendarInstalled() -> Bool {
    if let url = URL(string: "com.google.calendar://") {
        return UIApplication.shared.canOpenURL(url)
    }
    return false
}

func createGoogleCalendarEventWeb(title: String, location: String, startDate: Date, endDate: Date, details: String) {
    // Format the start and end dates
    let formattedStartDate = formatDateToISO8601(startDate)
    let formattedEndDate = formatDateToISO8601(endDate)
    
    let urlString = "https://www.google.com/calendar/render?action=TEMPLATE&text=\(title)&dates=\(formattedStartDate)/\(formattedEndDate)&location=\(location)&details=\(details)"
    if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


//Google Maps
func isGoogleMapsInstalled() -> Bool {
    if let url = URL(string: "comgooglemaps://") {
        return UIApplication.shared.canOpenURL(url)
    }
    return false
}


func openGoogleMaps(address: String? = nil, latitude: Double? = nil, longitude: Double? = nil, query: String? = nil) {
    var urlString = "comgooglemaps://"
    
    // Check if the URL should open with a location or a search query
    if let address = address {
        urlString += "?q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    } else if let latitude = latitude, let longitude = longitude {
        urlString += "?q=\(latitude),\(longitude)"
    } else if let query = query {
        urlString += "?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    }
    
    // Create the URL and open Google Maps if available
    if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        print("Google Maps app is not installed or cannot be opened.")
    }
}


// Instagram
func canOpenInstagram() -> Bool {
    let url = URL(string: "instagram-stories://share")!
    return UIApplication.shared.canOpenURL(url)
}

func shareToInstagram(backgroundImage: UIImage, appID: String) {
    guard let imageData = backgroundImage.pngData() else { return }

    let urlScheme = URL(string: "instagram-stories://share?source_application=\(appID)")!

    if UIApplication.shared.canOpenURL(urlScheme) {
        // Prepare the pasteboard item with the image data
        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData
        ]
        UIPasteboard.general.setItems([pasteboardItems], options: [
            UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
        ])

        // Open Instagram
        UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
    } else {
        // Instagram is not installed
        print("Instagram is not installed")
    }
}
