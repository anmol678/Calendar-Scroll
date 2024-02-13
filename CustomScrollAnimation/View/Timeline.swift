//
//  Timeline.swift
//  CustomScrollAnimation
//
//  Created by Balaji Venkatesh on 15/11/23.
//

import SwiftUI

struct Timeline: View {
    @EnvironmentObject var store: CalendarStore
    
    /// View Properties
    var safeArea: EdgeInsets
    var body: some View {
        let maxHeight = calendarHeight - (calendarTitleViewHeight + weekLabelHeight + safeArea.top + verticalPadding + verticalPadding)
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                CalendarView()
                
                VStack(spacing: 15) {
                    ForEach(1...15, id: \.self) { _ in
                        CardView()
                    }
                }
                .padding(15)
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(CustomScrollBehaviour(maxHeight: maxHeight))
    }
    
    /// Test Card View (For Scroll Content)
    @ViewBuilder
    func CardView() -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.secondary)
            .frame(height: 70)
            .overlay(alignment: .leading) {
                HStack(spacing: 12) {
                    Circle()
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 6, content: {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 100, height: 5)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 70, height: 5)
                    })
                }
                .foregroundStyle(.white.opacity(0.25))
                .padding(15)
            }
    }
    
    /// Calendar View
    @ViewBuilder
    func CalendarView() -> some View {
        GeometryReader {
            let size = $0.size
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
            /// Converting Scroll into Progress
            let maxHeight = size.height - (calendarTitleViewHeight + weekLabelHeight + safeArea.top + verticalPadding + verticalPadding + gridHeight)
            let progress = max(min((-minY / maxHeight), 1), 0)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text("\(currentMonth) \(year)")
                        .font(.largeTitle)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: calendarTitleViewHeight)
                .padding(.horizontal, horizontalPadding)
                
                /// Day Labels
                HStack(spacing: 0) {
                    ForEach(Calendar.current.weekdaySymbols, id: \.self) { symbol in
                        Text(symbol.prefix(3))
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: weekLabelHeight, alignment: .bottom)
                
                /// Calendar Grid View
                CalendarTabView() { timeperiod in
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0, content: {
                        ForEach(timeperiod.dates) { day in
                            Text(day.shortSymbol)
                                .foregroundStyle(day.ignored ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: gridHeight)
                                .overlay(alignment: .bottom, content: {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 5, height: 5)
                                        .opacity(Calendar.current.isDate(day.date, inSameDayAs: store.selectedDate) ? 1 : 0)
                                })
                                .contentShape(.rect)
                                .onTapGesture {
                                    store.selectedDate = day.date
                                }
                        }
                    })
                    .frame(height: store.scope == .week ? gridHeight : calendarGridHeight - ((calendarGridHeight - gridHeight) * progress), alignment: .top)
                    .offset(y: store.scope == .week ? 0 : ((weekRow * -gridHeight) * progress))
                    .contentShape(.rect)
                    .clipped()
                }
                
            }
            .foregroundStyle(.white)
            .padding(.top, safeArea.top)
            .padding(.vertical, verticalPadding)
            .frame(maxHeight: .infinity)
            .frame(height: size.height - (maxHeight * progress), alignment: .top)
            .background(.regularMaterial)
            /// Sticking it to top
            .clipped()
            .contentShape(.rect)
            .offset(y: -minY)
            .onChange(of: progress) { oldValue, newValue in
                if oldValue != newValue {
                    if newValue == 1 {
                        store.updateScope(.week)
                    } else if newValue == 0 {
                        store.updateScope(.month)
                    } else {
                        store.updateScope(.transition)
                    }
                }
            }
        }
        .frame(height: calendarHeight)
        .zIndex(1000)
    }
    
    /// Date Formatter
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: store.selectedMonth)
    }
    
    /// Current Month String
    var currentMonth: String {
        return format("MMMM")
    }
    
    /// Selected Year
    var year: String {
        return format("YYYY")
    }
    
    var weekRow: CGFloat {
        if let index = store.months[1].dates.firstIndex(where: { $0.date == store.selectedWeek }) {
            return CGFloat(index / 7).rounded()
        }
        
        return 0
    }
    
    /// View Heights & Paddings
    var calendarHeight: CGFloat {
        return calendarTitleViewHeight + weekLabelHeight + calendarGridHeight + safeArea.top + verticalPadding + verticalPadding
    }
    
    var calendarTitleViewHeight: CGFloat {
        return 44.0
    }
    
    var weekLabelHeight: CGFloat {
        return 20.0
    }
    
    var calendarGridHeight: CGFloat {
        return 6 * gridHeight
    }
    
    var gridHeight: CGFloat {
        return 40.0
    }
    
    var horizontalPadding: CGFloat {
        return 15.0
    }
    
    var verticalPadding: CGFloat {
        return 5.0
    }
}

/// Custom Scroll Behaviour
struct CustomScrollBehaviour: ScrollTargetBehavior {
    var maxHeight: CGFloat
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < maxHeight {
            target.rect = .zero
        }
        
        if target.rect.minY < context.containerSize.height / 4, context.velocity.dy < 0 {
            target.rect.origin.y = 0.0
        }
    }
}

#Preview {
    ContentView()
}
