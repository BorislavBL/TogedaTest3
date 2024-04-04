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
        // If not today or tomorrow, format the date as you desire
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        date = dateFormatter.string(from: inputDate)
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


