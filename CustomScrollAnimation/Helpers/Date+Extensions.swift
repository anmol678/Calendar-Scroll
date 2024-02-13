//
//  Date+Extensions.swift
//  CustomScrollAnimation
//
//  Created by Balaji Venkatesh on 15/11/23.
//

import SwiftUI

/// Date Extensions
extension Date {
    
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }

    func startOfMonth() -> Date {
            let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }

    func addingMonths(_ months: Int) -> Date {
            let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: months, to: self)!
    }

    func addingWeeks(_ weeks: Int) -> Date {
            let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: weeks, to: self)!
    }
    
    var shortDaySymbol: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
}
