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
        TimePeriod(index: index, dates: datesFor(month: date), referenceDate: date)
    }
    
    private func week(for date: Date, with index: Int) -> TimePeriod {
        TimePeriod(index: index, dates: datesFor(week: date), referenceDate: date)
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
        let range = calendar.range(of: .day, in: .month, for: month)
        let firstDayOfMonth = month.startOfMonth()
        let firstWeekDayIndex = calendar.component(.weekday, from: firstDayOfMonth) - 1
        return (-firstWeekDayIndex...41).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth),
                  let range = range else {
                return nil
            }
            let isIgnored = offset < 0 || !range.contains(offset + 1)
            return Day(date: date, ignored: isIgnored)
        }
    }
    
    private func datesFor(week: Date) -> [Day] {
        let startOfWeek = week.startOfWeek()
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else {
                return nil
            }
            return Day(date: date)
        }
    }
    
}

