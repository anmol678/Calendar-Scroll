//
//  Day.swift
//  CustomScrollAnimation
//
//  Created by Balaji Venkatesh on 15/11/23.
//

import SwiftUI

struct Day: Identifiable {
    var id: UUID
    var shortSymbol: String
    var date: Date
    /// Previous/Next Month Excess Dates
    var ignored: Bool
    
    init(date: Date, ignored: Bool = false) {
        self.id = UUID()
        self.shortSymbol = date.shortDaySymbol
        self.date = date
        self.ignored = ignored
    }
}
