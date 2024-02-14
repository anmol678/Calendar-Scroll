//
//  CalendarScroll.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/14/24.
//

import SwiftUI

struct CalendarConfigs {
    
    let safeArea: EdgeInsets
    
    var minCalendarHeight: CGFloat {
        calendarTitleViewHeight + weekLabelHeight + minCalendarGridHeight + 2 * verticalPadding + safeArea.top
    }
    
    var maxCalendarHeight: CGFloat {
        calendarTitleViewHeight + weekLabelHeight + maxCalendarGridHeight + 2 * verticalPadding + safeArea.top
    }
    
    var calendarTitleViewHeight: CGFloat {
        44.0
    }
    
    var weekLabelHeight: CGFloat {
        20.0
    }
    
    var minCalendarGridHeight: CGFloat {
        rowHeight
    }
    
    var maxCalendarGridHeight: CGFloat {
        6 * rowHeight
    }
    
    var rowHeight: CGFloat {
        40.0
    }
    
    var horizontalPadding: CGFloat {
        16.0
    }
    
    var verticalPadding: CGFloat {
        5.0
    }
    
}

enum DragState {
    case inactive
    case dragging(dy: CGFloat)
    
    var dy: CGFloat {
        switch self {
            case .inactive:
                return .zero
            case .dragging(let dy):
                return dy
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

struct CalendarScroll: View {
    @EnvironmentObject var store: CalendarStore
    
    @State private var dragState = DragState.inactive
    
    private var config: CalendarConfigs
    
    init(safeArea: EdgeInsets) {
        config = CalendarConfigs(safeArea: safeArea)
    }
    
    var body: some View {
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
            
            CalendarView()
                .coordinateSpace(.named("calendar"))
                .zIndex(1000)
        }
    }
    
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
    
    @ViewBuilder
    func CalendarView() -> some View {
        let progress = store.scope == .month ? max(min(-dragState.dy/requiredHeightChange, 1), 0) : min(max(dragState.dy/requiredHeightChange, 0), 1)
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text("\(format("MMMM")) \(format("YYYY"))")
                    .font(.largeTitle)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: config.calendarTitleViewHeight)
            .padding(.horizontal, config.horizontalPadding)
            
            HStack(spacing: 0) {
                ForEach(Calendar.current.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol.prefix(3))
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: config.weekLabelHeight)
            
            GeometryReader { geo in
                let frame = geo.frame(in: .named("calendar"))
                
                CalendarTabView(dragging: dragState.isDragging) { timeperiod in
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0, content: {
                        ForEach(timeperiod.dates) { day in
                            Text(day.shortSymbol)
                                .foregroundStyle(day.ignored ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: config.rowHeight)
                                .overlay(alignment: .center, content: {
                                    RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                                        .fill(.white)
                                        .frame(width: config.rowHeight*1.2, height: config.rowHeight*0.7)
                                        .opacity(Calendar.current.isDate(day.date, inSameDayAs: store.selectedDate) ? 0.5 : 0)
                                })
                                .contentShape(.rect)
                                .onTapGesture {
                                    store.selectedDate = day.date
                                }
                        }
                    })
                    .frame(maxHeight: .infinity)
                    .frame(height: frame.height, alignment: .top)
                    .offset(y: store.scope == .month ? requiredOffsetChange * progress : (dragState.isDragging ? requiredOffsetChange * (1-progress) : 0))
                    .contentShape(.rect)
                    .clipped()
                }
                .onDragGesture(
                    onUpdate: { gesture in
                        if store.scope == .week && gesture.translation.height < 0 {
                            dragState = .inactive
                            return
                        }
                        
                        dragState = .dragging(dy: gesture.translation.height)
                    },
                    onEnd: { gesture in
                        let threshold = requiredHeightChange / 2
                        let velocityThreshold: CGFloat = 800.0
                        
                        if gesture.translation.height > threshold || gesture.velocity.height > velocityThreshold {
                            store.setScope(.month)
                        }
                        
                        if gesture.translation.height < threshold || gesture.velocity.height < -velocityThreshold {
                            store.setScope(.week)
                        }
                        
                        dragState = .inactive
                    },
                    onCancel: {
                        dragState = .inactive
                    }
                )
//                .gesture(
//                    DragGesture(minimumDistance: 30.0)
//                        .onChanged({ gesture in
//                            if store.scope == .week && gesture.translation.height < 0 {
//                                dragState = .inactive
//                                return
//                            }
//                            
//                            withAnimation(.spring(duration: 0.3)) {
//                                dragState = .dragging(dy: gesture.translation.height)
//                            }
//                        })
//                        .onEnded({ gesture in
//                            withAnimation(.spring(duration: 0.3)) {
//                                let threshold = requiredHeightChange / 2
//                                let velocityThreshold: CGFloat = 800.0
//                                
//                                if gesture.translation.height > threshold || gesture.velocity.height > velocityThreshold {
//                                    store.setScope(.month)
//                                }
//                                
//                                if gesture.translation.height < threshold || gesture.velocity.height < -velocityThreshold {
//                                    store.setScope(.week)
//                                }
//                                
//                                dragState = .inactive
//                            }
//                        })
//                )
            }
        }
        .foregroundStyle(.white)
        .padding(.top, config.safeArea.top)
        .padding(.vertical, config.verticalPadding)
        .frame(height: calendarHeight)
        .background(.red.gradient)
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: store.selectedMonth)
    }
    
    var weekRow: CGFloat {
        if let index = store.currentMonth.dates.firstIndex(where: { $0.date == store.selectedWeek }) {
            return CGFloat(index / 7).rounded()
        }
        
        return 0
    }
    
    var requiredOffsetChange: CGFloat {
        return -weekRow * config.rowHeight
    }
    
    var requiredHeightChange: CGFloat {
        return config.maxCalendarGridHeight - config.minCalendarGridHeight
    }
    
    var calendarHeight: CGFloat {
        let height = store.scope == .week ? config.minCalendarHeight : config.maxCalendarHeight
        return min(max(height + dragState.dy, config.minCalendarHeight), config.maxCalendarHeight)
    }
}

//#Preview {
//    CalendarScroll()
//}
