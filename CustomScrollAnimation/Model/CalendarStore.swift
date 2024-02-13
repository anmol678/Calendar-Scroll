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
}

class CalendarStore: ObservableObject {
    
    private let calendar = Calendar.current
    
    @Published var months: [TimePeriod] = []
    @Published var weeks: [TimePeriod] = []
    
    @Published var selectedDate: Date {
        didSet {
            if let index = months.firstIndex(where: { $0.referenceDate == selectedMonth }), index != 1 {
                selectedMonth = months[index].referenceDate
            }
            calcTimePeriod(with: selectedDate, weekOnly: true)
        }
    }
    
    @Published var selectedMonth: Date
    @Published var selectedWeek: Date
    
    @Published var scope: CalendarScope

    init(with date: Date = Date()) {
        self.selectedDate = calendar.startOfDay(for: date)
        self.selectedMonth = date.getDateFor(.year, .month)
        self.selectedWeek = date.getDateFor(.yearForWeekOfYear, .weekOfYear)
        self.scope = .month
        calcTimePeriod(with: selectedDate)
    }

    private func calcTimePeriod(with date: Date, weekOnly: Bool = false) {

        if !weekOnly {
            let monthDate = date.getDateFor(.year, .month)
            selectedMonth = monthDate
            months = [
                month(for: calendar.date(byAdding: .month, value: -1, to: monthDate)!, with: -1),
                month(for: monthDate, with: 0),
                month(for: calendar.date(byAdding: .month, value: 1, to: monthDate)!, with: 1)
            ]
        }
                
        if let index = months.firstIndex(where: { $0.referenceDate == date }) {
            if index == 1 && months[index].dates.contains(where: { $0.date == selectedDate }) {
                let weekDate = selectedDate.getDateFor(.yearForWeekOfYear, .weekOfYear)
                selectedWeek = weekDate
                weeks = [
                    week(for: calendar.date(byAdding: .weekOfYear, value: -1, to: weekDate)!, with: -1),
                    week(for: weekDate, with: 0),
                    week(for: calendar.date(byAdding: .weekOfYear, value: 1, to: weekDate)!, with: 1)
                ]
                return
            }
        }
       
        let weekDate = date.getDateFor(.yearForWeekOfYear, .weekOfYear)
        selectedWeek = weekDate
        weeks = [
            week(for: calendar.date(byAdding: .weekOfYear, value: -1, to: weekDate)!, with: -1),
            week(for: weekDate, with: 0),
            week(for: calendar.date(byAdding: .weekOfYear, value: 1, to: weekDate)!, with: 1)
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

        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else { return .init(index: index, dates: [], referenceDate: date) }

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
                let oldSelectedWeekMonth = selectedWeek.getDateFor(.year, .month)
                switch direction {
                    case .future:
                        selectedWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedWeek)!
                    case .past:
                        selectedWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedWeek)!
                    case .unknown:
                        selectedWeek = selectedWeek
                }
                
                let newSelectedWeekMonth = selectedWeek.getDateFor(.year, .month)
                if oldSelectedWeekMonth != newSelectedWeekMonth {
                    selectedMonth = newSelectedWeekMonth
                }
                
                calcTimePeriod(with: selectedWeek)
                
//                let selectedDateWeek = selectedDate.getDateFor(.yearForWeekOfYear, .weekOfYear)
//                if let index = weeks.firstIndex(where: { $0.referenceDate == selectedDateWeek }) {
//                    if index == 1 {
//                        calcTimePeriod(with: selectedDate)
//                        return
//                    }
//                }
//                
//                calcTimePeriod(with: selectedWeek)
                
            case .month:
                switch direction {
                    case .future:
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth)!
                    case .past:
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth)!
                    case .unknown:
                        selectedMonth = selectedMonth
                }
                
//                let selectedDateMonth = selectedDate.getDateFor(.year, .month)
//                if let index = months.firstIndex(where: { $0.referenceDate == selectedDateMonth }) {
//                    if index == 1 {
//                        selectedWeek = selectedDate.getDateFor(.yearForWeekOfYear, .weekOfYear)
//                        calcTimePeriod(with: selectedDate)
//                        return
//                    }
//                }
//                selectedWeek = selectedMonth.getDateFor(.yearForWeekOfYear, .weekOfYear)
                
                // if selectedDate in selectedMonth
                
                calcTimePeriod(with: selectedMonth)
        }
        
    }
    
    func updateScope(_ scope: CalendarScope) {
        if scope == .week {
            if weeks[1].dates.contains(where: { $0.date == selectedDate }) {
                selectedMonth = selectedDate.getDateFor(.year, .month)
                calcTimePeriod(with: selectedDate)
            }
        } else {
            if months[1].dates.contains(where: { $0.date == selectedDate }) {
                print("inhere")
            }
            print("here")
        }
        
        self.scope = scope
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

