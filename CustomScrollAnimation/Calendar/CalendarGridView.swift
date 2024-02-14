//
//  CalendarGridView.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/14/24.
//

import SwiftUI

struct CalendarGridView: View {
    
    var timeperiod: TimePeriod
    
    @Binding var selectedDate: Date
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0, content: {
            ForEach(timeperiod.dates) { dayView($0) }
        })
    }
    
    @ViewBuilder 
    func dayView(_ day: Day) -> some View {
        Text(day.shortSymbol)
            .foregroundStyle(day.ignored ? .secondary : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: CalendarConfigs.rowHeight)
            .overlay(alignment: .center, content: {
                dayOverlay(day)
            })
            .contentShape(.rect)
            .onTapGesture {
                selectedDate = day.date
            }
    }
    
    @ViewBuilder
    func dayOverlay(_ day: Day) -> some View {
        RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
            .fill(.white)
            .frame(width: CalendarConfigs.rowHeight*1.2, height: CalendarConfigs.rowHeight*0.7)
            .opacity(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? 0.5 : 0)
    }
}

//#Preview {
//    CalendarGridView()
//}
