//
//  Timeline.swift
//  CustomScrollAnimation
//
//  Created by Balaji Venkatesh on 15/11/23.
//

import SwiftUI

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

struct Timeline: View {
    @EnvironmentObject var store: CalendarStore
    
    @State private var dragState = DragState.inactive
    
    
    /// View Properties
    var safeArea: EdgeInsets
    var body: some View {
        let maxHeight = calendarHeight - (calendarTitleViewHeight + weekLabelHeight + safeArea.top + verticalPadding + verticalPadding)
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: calendarHeight)

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

            CalendarView()
//                .frame(height: calendarHeight)
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
            let minY = dragState.translation.height
            /// Converting Scroll into Progress
            let maxHeight = size.height - (calendarTitleViewHeight + weekLabelHeight + safeArea.top + verticalPadding + verticalPadding + gridHeight)
            let progress = store.scope == .month ? max(min((-minY / maxHeight), 1), 0) : min(max(minY/(calendarGridHeight - gridHeight), 0), 1)
            
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
                    .background(Color.red)
                    .frame(height: store.scope == .week ? gridHeight : store.scope == .month ? calendarGridHeight - ((calendarGridHeight - gridHeight) * progress) : gridHeight + (calendarGridHeight - gridHeight)*progress, alignment: .top)
                    .offset(y: store.scope == .week ? 0 : store.scope == .month ? ((weekRow * -gridHeight) * progress) : (weekRow * -gridHeight * progress))
                    .contentShape(.rect)
                    .clipped()
                }
                
                /// handle inner frame ^ height and offset for scope == .transition ie when draggin down from week to month
                ///  bigger negative number means further up the content is, as the number decreases the content moves lower
                ///  inner height seems to be increasing slower that the outer frame height
                
            }
            .foregroundStyle(.white)
            .padding(.top, safeArea.top)
            .padding(.vertical, verticalPadding)
            .frame(maxHeight: .infinity)
            .frame(height: store.scope == .transition ? max(min(calMaxHeight, size.height + ((calendarGridHeight - gridHeight) * progress)), calendarHeight) : size.height - (maxHeight * progress), alignment: .top)
            .background(.blue)
            .gesture(
                DragGesture()
                    .onChanged{ gesture in
                        if store.scope == .week {
                            store.setScope(.transition)
                        }
                        dragState = .dragging(translation: gesture.translation)
                        
                        print("progress: \(minY/(calendarGridHeight-gridHeight))")
                        print("inner height: \(store.scope == .week ? gridHeight : store.scope == .month ? calendarGridHeight - ((calendarGridHeight - gridHeight) * progress) : calendarGridHeight*progress)")
                        print("offset: \(store.scope == .week ? 0 : store.scope == .month ? ((weekRow * -gridHeight) * progress) : (((6-weekRow) * gridHeight) * progress))")
                        
                        print(minY, progress)
                    }
                    .onEnded { gesture in
                        if gesture.translation.height < -(maxHeight / 4) {
                            store.setScope(.week)
                        } else if gesture.translation.height > (maxHeight / 4) {
                            store.setScope(.month)
                        }

                        dragState = .inactive
                        print("ended")
                    }
            )
            /// Sticking it to top
            .clipped()
            .contentShape(.rect)
            .offset(y: -minY)
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
        
        if store.scope == .week || store.scope == .transition {
            return calendarTitleViewHeight + weekLabelHeight + gridHeight + safeArea.top + verticalPadding + verticalPadding
        }
        
        
        return calendarTitleViewHeight + weekLabelHeight + calendarGridHeight + safeArea.top + verticalPadding + verticalPadding
    }
    
    var calMaxHeight: CGFloat {
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
