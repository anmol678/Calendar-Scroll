//
//  Date+Extensions.swift
//  CustomScrollAnimation
//
//  Created by Balaji Venkatesh on 15/11/23.
//

import SwiftUI

/// Date Extensions
extension Date {
    static var currentMonth: Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: Calendar.current.dateComponents([.month, .year], from: .now)) else {
            return .now
        }
        
        return currentMonth
    }
    
    func getDateFor(_ components: Calendar.Component...) -> Date {
        let calendar = Calendar.current
        guard let date = calendar.date(from: calendar.dateComponents(Set(components), from: self)) else {
            return self
        }
        
        return date
    }
}
