//
//  Timeline.swift
//  CustomScrollAnimation
//
//  Created by Balaji Venkatesh on 15/11/23.
//

import SwiftUI

struct Timeline: View {
    @EnvironmentObject var store: CalendarStore
    
    @State var offset: CGFloat = 0
    
    /// View Properties
    var safeArea: EdgeInsets
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: max(calendarHeight+offset*2, calendarHeight-calendarGridHeight+gridHeight))
                    
                    VStack(spacing: 15) {
                        ForEach(1...15, id: \.self) { _ in
                            CardView()
                        }
                    }
                    .padding(15)
                }
            }
            .scrollIndicators(.hidden)
            
            ScrollView(.vertical) {
                CalendarView()
                    .frame(height: max(calendarHeight+offset, calendarHeight-calendarGridHeight+gridHeight))
                
                Color.clear
                    .frame(height: max(calendarHeight+offset, calendarHeight-calendarGridHeight+gridHeight))
            }
            .scrollTargetBehavior(CustomScrollBehaviour(maxTranslation: maxTranslation))
            .frame(height: max(calendarHeight+offset*2, calendarHeight-calendarGridHeight+gridHeight))
//            .background(.red)
            .scrollIndicators(.hidden)
            .zIndex(1000)
        }
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
//            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
            let minY = -$0.frame(in: .global).minY
            /// Converting Scroll into Progress
            let translation = size.height - minCalendarHeight
            let progress = max(min((minY / translation), 1), 0)
            
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
//                    .background(.green)
                    .offset(y: store.scope == .week ? 0 : ((weekRow * -gridHeight) * progress))
                    .contentShape(.rect)
                    .clipped()
                }
                
            }
            .foregroundStyle(.white)
            .padding(.top, safeArea.top)
            .padding(.vertical, verticalPadding)
            .frame(height: store.scope == .week ? minCalendarHeight : calendarHeight)
            .background(.regularMaterial)
            /// Sticking it to top
            .clipped()
            .contentShape(.rect)
            .offset(y: minY)
            .onChange(of: progress) { oldValue, newValue in
                if oldValue != newValue {
                    if newValue == 1 {
                        store.setScope(.week)
                    } else if newValue == 0 {
                        store.setScope(.month)
                    } else {
                        store.setScope(.transition)
                    }
                }
            }
            .onChange(of: minY) { oldValue, newValue in
                offset = -newValue
            }
        }
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
        return calendarTitleViewHeight + weekLabelHeight + calendarGridHeight + safeArea.top + verticalPadding*2
    }
    
    var minCalendarHeight: CGFloat {
        return calendarHeight - maxTranslation
    }
    
    var maxTranslation: CGFloat {
        return calendarGridHeight - gridHeight
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
        return 38.0
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
    var maxTranslation: CGFloat
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        
        print(Date().description, target.rect.minY)
//        print(maxHeight, target.rect.minY, target.rect.origin.y)
//        print(context.containerSize.height, context.velocity.dy)
        
        let threshold = maxTranslation/2
        
        if threshold/2 < target.rect.minY {
            target.rect.origin.y = threshold
        } else {
            target.rect.origin.y = 0.0
        }
    }
}

#Preview {
    ContentView()
}
