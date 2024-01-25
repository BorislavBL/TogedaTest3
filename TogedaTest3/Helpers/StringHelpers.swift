//
//  StringHelpers.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import Foundation

func interestsOrder(_ interests: [Interest]) -> String {
    var text = ""
    for i in interests.indices {
        if i < 3 {
            text += "\(interests[i].icon) \(interests[i].name) "
        }
    }
    
    return text
}
