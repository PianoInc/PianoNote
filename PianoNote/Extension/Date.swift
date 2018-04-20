//
//  Date.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 28..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension Date {
    
    // Date값을 주어진 Time format에 맞춰 반환한다.
    var timeFormat: String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        
        var todayComponents = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        todayComponents.hour = 0
        todayComponents.minute = 0
        let today = calendar.date(from: todayComponents)!
        
        let interval = calendar.dateComponents([.year, .month, .day, .hour], from: self, to: today)
        if interval.year! > 0 {
            return String(format: "dateYearPast".locale, components.year!, components.month!)
        } else if interval.month! > 0 {
            return String(format: "dateYear".locale, interval.month!)
        } else if interval.day! > 6 {
            return "dateMonth".locale
        } else if interval.day! > 0 {
            return "dateWeek".locale
        } else if interval.hour! > 0 {
            return "dateYesterday".locale
        } else {
            return "dateToday".locale
        }
    }
    
}

