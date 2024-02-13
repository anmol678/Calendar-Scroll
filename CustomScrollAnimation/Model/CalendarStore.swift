//
//  CalendarStore.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/13/24.
//

import Foundation

struct TimePeriod {
    let index: Int
    let dates: [Day]
    var referenceDate: Date
}

enum CalendarScope {
    case week
    case month
    case transition
}

class CalendarStore: ObservableObject {
    
    private let calendar = Calendar.current
    
    @Published var months: [TimePeriod] = []
    @Published var weeks: [TimePeriod] = []
    
    @Published var selectedDate: Date {
        didSet {
            updateSelectedWeekAndMonth()
            calculateTimePeriods()
        }
    }
    
    @Published var selectedMonth: Date
    @Published var selectedWeek: Date
    
    @Published var scope: CalendarScope
    
    init(with date: Date = Date()) {
        let startOfDay = calendar.startOfDay(for: date)
        self.selectedDate = startOfDay
        self.selectedMonth = startOfDay.startOfMonth()
        self.selectedWeek = startOfDay.startOfWeek()
        self.scope = .month
        calculateTimePeriods()
    }
    
    private func updateSelectedWeekAndMonth() {
        selectedWeek = selectedDate.startOfWeek()
        if scope == .month && months[1].dates.contains(where: { $0.date == selectedDate }) {
            
        } else {
            selectedMonth = selectedDate.startOfMonth()
        }
    }
    
    private func calculateTimePeriods() {
        months = [
            month(for: selectedMonth.addingMonths(-1), with: -1),
            month(for: selectedMonth, with: 0),
            month(for: selectedMonth.addingMonths(1), with: 1)
        ]
        weeks = [
            week(for: selectedWeek.addingWeeks(-1), with: -1),
            week(for: selectedWeek, with: 0),
            week(for: selectedWeek.addingWeeks(1), with: 1)
        ]
    }
    
    private func month(for date: Date, with index: Int) -> TimePeriod {
        let days = self.datesFor(month: date)
        return TimePeriod(index: index, dates: days, referenceDate: date)
    }
    
    private func week(for date: Date, with index: Int) -> TimePeriod {
        var result: [Day] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return TimePeriod(index: index, dates: [], referenceDate: date)
        }
        
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                let shortSymbol = formatter.string(from: weekday)
                result.append(Day(shortSymbol: shortSymbol, date: weekday))
            }
        }
        
        return TimePeriod(index: index, dates: result, referenceDate: date)
    }
    
    func selectToday() {
        select(date: Date())
    }
    
    func select(date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }
    
    func update(to direction: TimeDirection) {
        switch scope {
            case .week:
                selectedWeek = selectedWeek.addingWeeks(direction.rawValue)
            case .month:
                selectedMonth = selectedMonth.addingMonths(direction.rawValue)
            case .transition:
                return
        }
        
        calculateTimePeriods()
        
        switch scope {
            case .week:
                if weeks[1].dates.contains(where: { $0.date == selectedDate }) {
                    selectedMonth = selectedDate.startOfMonth()
                } else {
                    selectedMonth = selectedWeek.startOfMonth()
                }
            case .month:
                if months[1].dates.contains(where: { $0.date == selectedDate }) {
                    selectedWeek = selectedDate.startOfWeek()
                } else {
                    selectedWeek = selectedMonth.startOfWeek()
                }
            case .transition:
                return
        }
    }
    
    func updateScope(_ newScope: CalendarScope) {
        guard scope != newScope else { return }
        
        scope = newScope
        
        calculateTimePeriods()
        
        switch newScope {
            case .week:
                if weeks[1].dates.contains(where: { $0.date == selectedDate }) {
                    selectedMonth = selectedDate.startOfMonth()
                } else {
                    selectedMonth = selectedWeek.startOfMonth()
                }
            case .month:
                if months[1].dates.contains(where: { $0.date == selectedDate }) {
                    selectedWeek = selectedDate.startOfWeek()
                } else {
                    selectedWeek = selectedMonth.startOfWeek()
                }
            case .transition:
                return
        }
    }
    
    private func datesFor(month: Date) -> [Day] {
        var days: [Day] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        guard let range = calendar.range(of: .day, in: .month, for: month)?.compactMap({ value -> Date? in
            return calendar.date(byAdding: .day, value: value - 1, to: month)
        }) else {
            return days
        }
        
        let firstWeekDay = calendar.component(.weekday, from: range.first!)
        
        for index in Array(0..<firstWeekDay - 1).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: range.first!) else { return days }
            let shortSymbol = formatter.string(from: date)
            
            days.append(Day(shortSymbol: shortSymbol, date: date, ignored: true))
        }
        
        range.forEach { date in
            let shortSymbol = formatter.string(from: date)
            days.append(Day(shortSymbol: shortSymbol, date: date))
        }
        
        let lastWeekDay = 7 - calendar.component(.weekday, from: range.last!)
        
        if lastWeekDay > 0 {
            for index in 0..<lastWeekDay {
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: range.last!) else { return days }
                let shortSymbol = formatter.string(from: date)
                
                days.append(Day(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }
        
        if days.count == 35 {
            let lastWeekDay = days.last!.date
            for index in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: lastWeekDay) else { return days }
                let shortSymbol = formatter.string(from: date)
                
                days.append(Day(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }
        
        return days
    }
}

