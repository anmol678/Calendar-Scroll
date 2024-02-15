//
//  CalendarView.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/14/24.
//

import SwiftUI


struct CalendarView: View {
    @EnvironmentObject var store: CalendarStore
    
    @State private var dragState = DragState.inactive
    
    private var config: CalendarConfigs
    
    init(safeArea: EdgeInsets) {
        config = CalendarConfigs(safeArea: safeArea)
    }
    
    var calendarHeight: CGFloat {
        DragManager.calendarHeight(for: dragState, in: store.scope, with: config)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: calendarHeight)
                    CardStack()
                }
            }
            .scrollIndicators(.hidden)
            
            CalendarView()
                .coordinateSpace(.named("calendar"))
                .zIndex(1000)
        }
    }
    
    @ViewBuilder
    func CalendarView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CalendarHeader()
            WeekdayLabels()
            CalendarGrid()
        }
        .foregroundStyle(.white)
        .padding(.top, config.topPadding)
        .padding(.vertical, CalendarConfigs.verticalPadding)
        .frame(height: calendarHeight)
        .background(.thinMaterial)
    }
    
    @ViewBuilder
    func CalendarHeader() -> some View {
        HStack(alignment: .top) {
            Text("\(store.selectedMonth.monthYear)")
                .font(.largeTitle)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: CalendarConfigs.calendarTitleViewHeight)
        .padding(.horizontal, CalendarConfigs.horizontalPadding)
    }
    
    @ViewBuilder
    func WeekdayLabels() -> some View {
        HStack(spacing: 0) {
            ForEach(Calendar.current.weekdaySymbols, id: \.self) { symbol in
                Text(symbol.prefix(3))
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: CalendarConfigs.weekLabelHeight)
    }
    
    @ViewBuilder
    func CalendarGrid() -> some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .named("calendar"))
            
            CalendarContentView(dragging: dragState.isDragging) { timeperiod in
                CalendarGridView(timeperiod: timeperiod, selectedDate: $store.selectedDate)
                    .frame(maxHeight: .infinity)
                    .frame(height: frame.height, alignment: .top)
                    .animation(nil) {
                        $0.offset(y: DragManager.contentOffset(for: dragState, in: store.scope, with: store.selectedWeekRow))
                    }
                    .contentShape(.rect)
                    .clipped()
            }
            .onDragGesture(
                onUpdate: { dy in
                    if store.scope == .week && dy < 0 {
                        dragState = .inactive
                        return
                    }
                    
                    dragState = .dragging(dy: dy)
                },
                onEnd: { gesture in
                    if dragState.isDragging {
                        let translationThreshold = CalendarConfigs.maxTranslationY / 2
                        let velocityThreshold: CGFloat = 450
                        
                        let dy = gesture.translation.height
                        let velocity = gesture.velocity.height
                        
                        if store.scope == .week {
                            if dy > translationThreshold || velocity > velocityThreshold {
                                store.setScope(.month)
                            }
                        } else if store.scope == .month {
                            if dy < -translationThreshold || velocity < -velocityThreshold {
                                store.setScope(.week)
                            }
                        }
                            
                        dragState = .inactive
                    }
                },
                onCancel: {
                    if dragState.isDragging {
                        dragState = .inactive
                    }
                }
            )
        }
        .onChange(of: dragState) { oldValue, newValue in
            if oldValue.isDragging != newValue.isDragging {
                store.calculateTimePeriods()
            }
        }
    }
    
}

//#Preview {
//    CalendarScroll()
//}
