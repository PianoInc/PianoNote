//
//  Date.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 28..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/**
 ISO8601형태의 Str 또는 Date 값을 주어진 timeFormat에 맞게 변환한다.
 - parameter iSO8601: 변환하고자 하는 ISO8601 str값.
 - parameter date: 적용하려는 Date값.
 */
func timeFormat(_ date: Date?) -> String {
    guard let date = date else {return ""}
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    
    var todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
    todayComponents.hour = 0
    todayComponents.minute = 0
    let today = calendar.date(from: todayComponents)!
    
    let interval = calendar.dateComponents([.year, .month, .day, .hour], from: date, to: today)
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

