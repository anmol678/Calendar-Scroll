//
//  CalendarView.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/13/24.
//

import SwiftUI

enum TimeDirection {
    case future
    case past
    case unknown
}

struct CalendarTabView<Content: View>: View {
    @EnvironmentObject var store: CalendarStore

    @State private var activeTab: Int = 1
    @State private var direction: TimeDirection = .unknown

    let content: (_ week: TimePeriod) -> Content

    init(@ViewBuilder content: @escaping (_ week: TimePeriod) -> Content) {
        self.content = content
    }

    var body: some View {
        var data: [TimePeriod] {
            switch store.scope {
                case .month:
                    store.months
                case .week:
                    store.weeks
            }
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
                        store.update(to: direction)
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

