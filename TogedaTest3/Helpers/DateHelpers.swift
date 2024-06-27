//
//  DateHelpers.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 21.11.23.
//

import Foundation

func separateDateAndTime(from inputDate: Date) -> (date: String, time: String, weekday: String) {
    let calendar = Calendar.current

    // Check if the date is today or tomorrow
    let date: String
    if calendar.isDateInToday(inputDate) {
        date = "Today"
    } else if calendar.isDateInTomorrow(inputDate) {
        date = "Tomorrow"
    } else {
        // Check if the input date is within the current year
        let currentYear = calendar.component(.year, from: Date())
        let inputYear = calendar.component(.year, from: inputDate)
        
        if currentYear == inputYear {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM"
            date = dateFormatter.string(from: inputDate)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            date = dateFormatter.string(from: inputDate)
        }
    }

    // Format the time
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    let time = timeFormatter.string(from: inputDate)

    // Get the weekday
    let weekdayFormatter = DateFormatter()
    weekdayFormatter.dateFormat = "EEEE"
    let weekday = weekdayFormatter.string(from: inputDate)

    return (date, time, weekday)
}


func formatDateAndTime(date: Date) -> String {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()

    // Check if the date is today or tomorrow
    if calendar.isDateInToday(date) {
        dateFormatter.dateFormat = "'Today,' HH:mm"
    } else if calendar.isDateInTomorrow(date) {
        dateFormatter.dateFormat = "'Tomorrow,' HH:mm"
    } else {
        // For any other day, show the date and time
        dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
    }

    return dateFormatter.string(from: date)
}

func formatDateAndTimeToStringTimeFormat(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return formatter.string(from: date)
}

func formatDateToDayAndMonthString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMM"
    return dateFormatter.string(from: date)
}

func calculateAge(from birthdateStr: String) -> Int? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard let birthdate = dateFormatter.date(from: birthdateStr) else {
        return nil
    }

    let calendar = Calendar.current
    let now = Date()
    let ageComponents = calendar.dateComponents([.year], from: birthdate, to: now)
    return ageComponents.year
}


func birthDayFromStringToDate(dateString: String) -> Date? {
    let dateFormatter = DateFormatter()

    // Set the date format that matches your input string
    dateFormatter.dateFormat = "yyyy-MM-dd"

    // Optionally, set the locale to posix to ensure the formatter does not use the user's locale
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    // Convert the string to a Date object
    if let date = dateFormatter.date(from: dateString) {
        return date
    } else {
        print("Invalid date format")
    }
    
    return nil
}


func formatDateForNotifications(from date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    // Calculate the difference in time components between the two dates
    let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: now)
    
    // Formatter for full dates (more than a week ago)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    
    // Check if the difference is less than a week
    if let week = components.weekOfYear, week > 0 {
        return dateFormatter.string(from: date)
    } else if let day = components.day, day > 0 {
        return "\(day) day\(day > 1 ? "s" : "") ago"
    } else if let hour = components.hour, hour > 0 {
        return "\(hour) hour\(hour > 1 ? "s" : "") ago"
    } else if let minute = components.minute, minute > 0 {
        return "\(minute) min\(minute > 1 ? "s" : "") ago"
    } else {
        return "Just now"
    }
}
