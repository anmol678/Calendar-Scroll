//
//  ContentView.swift
//  CustomScrollAnimation
//
//  Created by Balaji Venkatesh on 12/11/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var calendarStore: CalendarStore = CalendarStore()
    
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            
            CalendarScroll(safeArea: safeArea)
                .environmentObject(calendarStore)
                .ignoresSafeArea(.container, edges: .top)
        }
    }
}

#Preview {
    ContentView()
}
