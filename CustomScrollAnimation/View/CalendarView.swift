//
//  CalendarView.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/13/24.
//

import SwiftUI

enum TimeDirection: Int {
    case past = -1
    case unknown = 0
    case future = 1
}

struct CalendarTabView<Content: View>: View {
    @EnvironmentObject var store: CalendarStore

    @State private var activeTab: Int = 1
    @State private var direction: TimeDirection = .unknown
    
    var isDragging: Bool

    let content: (_ week: TimePeriod) -> Content

    init(dragging: Bool = false, @ViewBuilder content: @escaping (_ week: TimePeriod) -> Content) {
        self.isDragging = dragging
        self.content = content
    }

    var body: some View {
        var data: [TimePeriod] {
            store.scope == .week && !isDragging ? store.weeks : store.months
        }
        
        TabView(selection: $activeTab) {
            content(data[0])
                .frame(maxWidth: .infinity)
                .tag(0)

            content(data[1])
                .frame(maxWidth: .infinity)
                .tag(1)
                .onDisappear() {
                    if direction != .unknown {
                        store.scroll(in: direction)
                        direction = .unknown
                        activeTab = 1
                    }
                }

            content(data[2])
                .frame(maxWidth: .infinity)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: activeTab) { oldValue, newValue in
            if newValue == 0 {
                direction = .past
            } else if newValue == 2 {
                direction = .future
            }
        }
    }
}

