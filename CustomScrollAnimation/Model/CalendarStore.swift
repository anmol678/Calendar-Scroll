//
//  CalendarStore.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/13/24.
//

import Foundation

enum TimePeriodType {
    case week
    case month
}

struct TimePeriod {

    static let calendar = Calendar.current
    
    let index: Int
    let referenceDate: Date
    let dates: [Day]
    
    init(index: Int, referenceDate: Date, type: TimePeriodType) {
        self.index = index
        self.referenceDate = referenceDate
        switch type {
            case .week:
                self.dates = TimePeriod.datesFor(week: referenceDate)
            case .month:
                self.dates = TimePeriod.datesFor(month: referenceDate)
        }
    }
    
    static private func datesFor(month: Date) -> [Day] {
        let range = calendar.range(of: .day, in: .month, for: month)
        let firstDayOfMonth = month.startOfMonth()
        let firstWeekDayIndex = calendar.component(.weekday, from: firstDayOfMonth) - 1
        let numberOfDaysInWeek = 7
        let totalSlots = 6 * numberOfDaysInWeek // 6 weeks times 7 days

        return (0..<totalSlots).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - firstWeekDayIndex, to: firstDayOfMonth),
                  let range = range else {
                return nil
            }
            let dayOffset = offset - firstWeekDayIndex
            let isIgnored = dayOffset < 0 || !range.contains(dayOffset + 1)
            return Day(date: date, ignored: isIgnored)
        }
    }
    
    static private func datesFor(week: Date) -> [Day] {
        let startOfWeek = week.startOfWeek()
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else {
                return nil
            }
            return Day(date: date)
        }
    }
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
    
    private var currentWeek: TimePeriod {
        weeks[1]
    }
    
    var currentMonth: TimePeriod {
        months[1]
    }
    
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
        if scope == .month && currentMonth.dates.contains(where: { $0.date == selectedDate }) {
            
        } else {
            selectedMonth = selectedDate.startOfMonth()
        }
    }
    
    private func calculateTimePeriods() {
        months = [
            TimePeriod(index: -1, referenceDate: selectedMonth.addMonths(-1), type: .month),
            TimePeriod(index: 0, referenceDate: selectedMonth, type: .month),
            TimePeriod(index: 1, referenceDate: selectedMonth.addMonths(1), type: .month)
        ]
        weeks = [
            TimePeriod(index: -1, referenceDate: selectedWeek.addWeeks(-1), type: .week),
            TimePeriod(index: 0, referenceDate: selectedWeek, type: .week),
            TimePeriod(index: 1, referenceDate: selectedWeek.addWeeks(1), type: .week)
        ]
    }
    
    func selectToday() {
        select(date: Date())
    }
    
    func select(date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }
    
    func scroll(in direction: TimeDirection) {
        if scope == .week {
            selectedWeek = selectedWeek.addWeeks(direction.rawValue)
            calculateTimePeriods()
            
            if currentWeek.dates.contains(where: { $0.date == selectedDate }) {
                selectedMonth = selectedDate.startOfMonth()
            } else {
                selectedMonth = selectedWeek.startOfMonth()
            }
        } else if scope == .month {
            selectedMonth = selectedMonth.addMonths(direction.rawValue)
            calculateTimePeriods()
            
            if currentMonth.dates.contains(where: { $0.date == selectedDate }) {
                selectedWeek = selectedDate.startOfWeek()
            } else {
                selectedWeek = selectedMonth.startOfWeek()
            }
        }
    }
    
    func setScope(_ newScope: CalendarScope) {
        guard scope != newScope else { return }
        
        scope = newScope

        calculateTimePeriods()
        
        switch newScope {
            case .week:
                if currentWeek.dates.contains(where: { $0.date == selectedDate }) {
                    selectedMonth = selectedDate.startOfMonth()
                } else {
                    selectedMonth = selectedWeek.startOfMonth()
                }
            case .month:
                if currentMonth.dates.contains(where: { $0.date == selectedDate }) {
                    selectedWeek = selectedDate.startOfWeek()
                } else {
                    selectedWeek = selectedMonth.startOfWeek()
                }
            case .transition:
                return
        }
    }
    
}

