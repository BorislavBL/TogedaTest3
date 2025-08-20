//
//  Checkers.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.12.23.
//

import Foundation

func validDate(day: String, month: String, year: String) -> Bool{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    if dateFormatter.date(from:"\(year)-\(month)-\(day)") != nil && day.count == 2 && month.count == 2 && year.count == 4 {
        return true
    }
    else {
        return false
    }
}

func hasAge(day: String, month: String, year: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent date parsing
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone

    // Check for valid date format
    guard let birthDate = dateFormatter.date(from:"\(year)-\(month)-\(day)"),
          day.count == 2, month.count == 2, year.count == 4 else {
        return false
    }

    // Calculate the date 18 years ago from today
    let calendar = Calendar.current
    if let date18YearsAgo = calendar.date(byAdding: .year, value: -18, to: Date()) {
        return birthDate <= date18YearsAgo
    }

    return false
}

func validAge(day: String, month: String, year: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent date parsing
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone

    // Check for valid date format
    guard let birthDate = dateFormatter.date(from: "\(year)-\(month)-\(day)"),
          day.count == 2, month.count == 2, year.count == 4 else {
        return false
    }

    let calendar = Calendar.current
    let currentDate = Date()

    // Check if the person is not older than 120 years
    if let date120YearsAgo = calendar.date(byAdding: .year, value: -120, to: currentDate),
       birthDate < date120YearsAgo {
        return false // The person is older than 120
    }

    // The person is between 18 and 120 years old
    return true
}


func isValidEmail(testStr: String) -> Bool {
    let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: testStr)
    return result
}

func containsLink(text: String) -> Bool {
    // This is a basic regex pattern to check for URLs. It might not catch all URLs, but it will match common patterns.
    let pattern = "((https?|ftp)://|www\\.)[a-z0-9-]+(\\.[a-z0-9-]+)+([/?].*)?"
    let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    
    let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    
    return matches?.count ?? 0 > 0
}

func containsOnlyLetters(_ text: String) -> Bool {
    // Regex matches only letters (upper/lowercase)
    let pattern = "^[A-Za-z]+$"
    
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return false
    }
    
    let range = NSRange(location: 0, length: text.utf16.count)
    return regex.firstMatch(in: text, options: [], range: range) != nil
}
