//
//  CalendarScroll.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/14/24.
//

import SwiftUI


struct CalendarScroll: View {
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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text("\(format("MMMM")) \(format("YYYY"))")
                    .font(.largeTitle)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: CalendarConfigs.calendarTitleViewHeight)
            .padding(.horizontal, CalendarConfigs.horizontalPadding)
            
            HStack(spacing: 0) {
                ForEach(Calendar.current.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol.prefix(3))
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: CalendarConfigs.weekLabelHeight)
            
            GeometryReader { geo in
                let frame = geo.frame(in: .named("calendar"))
                
                CalendarTabView(dragging: dragState.isDragging) { timeperiod in
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0, content: {
                        ForEach(timeperiod.dates) { day in
                            Text(day.shortSymbol)
                                .foregroundStyle(day.ignored ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: CalendarConfigs.rowHeight)
                                .overlay(alignment: .center, content: {
                                    RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                                        .fill(.white)
                                        .frame(width: CalendarConfigs.rowHeight*1.2, height: CalendarConfigs.rowHeight*0.7)
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
                    .offset(y: DragManager.contentOffset(for: dragState, in: store.scope, with: store.selectedWeekRow))
                    .contentShape(.rect)
                    .clipped()
                }
                .onDragGesture(
                    onUpdate: { gesture in
                        let dy = gesture.translation.height
                        if store.scope == .week && dy < 0 {
                            dragState = .inactive
                            return
                        }
                        
                        dragState = .dragging(dy: dy)
                    },
                    onEnd: { gesture in
                        let dy = gesture.translation.height
                        let velocity = gesture.velocity.height
                        let translationThreshold = CalendarConfigs.maxTranslationY / 2
                        let velocityThreshold: CGFloat = 800.0
                        
                        if dy > translationThreshold || velocity > velocityThreshold {
                            store.setScope(.month)
                        }
                        
                        if dy < translationThreshold || velocity < -velocityThreshold {
                            store.setScope(.week)
                        }
                        
                        dragState = .inactive
                    },
                    onCancel: {
                        dragState = .inactive
                    }
                )
            }
            .onChange(of: dragState) { oldValue, newValue in
                if oldValue.isDragging != newValue.isDragging {
                    store.calculateTimePeriods()
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.top, config.topPadding)
        .padding(.vertical, CalendarConfigs.verticalPadding)
        .frame(height: calendarHeight)
        .background(.red.gradient)
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: store.selectedMonth)
    }
}

//#Preview {
//    CalendarScroll()
//}
