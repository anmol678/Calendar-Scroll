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
//    @Published private var weeks: [TimePeriod] = []
    
    @Published var selectedDate: Date {
        didSet {
            guard let selectedMonth = months.first(where: { $0.referenceDate == selectedMonth }) else {
                let newSelectedMonth = selectedDate.getDateFor(.year, .month)
                calcTimePeriod(with: newSelectedMonth)
                return
            }
        }
    }
    
    @Published var selectedMonth: Date
    
//    var data: [TimePeriod] {
//        switch self.scope {
//            case .month:
//                months
//            case .week:
//                weeks
//        }
//    }
    
    @Published var scope: CalendarScope

    init(with date: Date = Date()) {
        self.selectedDate = calendar.startOfDay(for: date)
        self.selectedMonth = date.getDateFor(.year, .month)
        self.scope = .month
        calcTimePeriod(with: selectedMonth)
    }

    private func calcTimePeriod(with date: Date) {
//        switch self.scope {
//            case .month:
                months = [
                    month(for: calendar.date(byAdding: .month, value: -1, to: date)!, with: -1),
                    month(for: date, with: 0),
                    month(for: calendar.date(byAdding: .month, value: 1, to: date)!, with: 1)
                ]
//            case .week:
//                weeks = [
//                    week(for: calendar.date(byAdding: .day, value: -7, to: date)!, with: -1),
//                    week(for: date, with: 0),
//                    week(for: calendar.date(byAdding: .day, value: 7, to: date)!, with: 1)
//                ]
//        }
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
        switch direction {
            case .future:
//                selectedDate = calendar.date(byAdding: .day, value: 7, to: selectedDate)!
                selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth)!
            case .past:
//                selectedDate = calendar.date(byAdding: .day, value: -7, to: selectedDate)!
                selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth)!
            case .unknown:
//                selectedDate = selectedDate
                selectedMonth = selectedMonth
        }

        calcTimePeriod(with: selectedMonth)
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

