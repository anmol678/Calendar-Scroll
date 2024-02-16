//
//  CalendarDragGesture.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/14/24.
//

import Foundation

enum DragState: Equatable {
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

struct DragManager {
    
    static func calendarHeight(for dragState: DragState, in scope: CalendarScope, with config: CalendarConfigs) -> CGFloat {
        let height = scope == .week ? config.minCalendarHeight : config.maxCalendarHeight
        return min(max(height + dragState.dy, config.minCalendarHeight), config.maxCalendarHeight)
    }
    
    static func contentOffset(for dragState: DragState, in scope: CalendarScope, with selectedRow: CGFloat) -> CGFloat {
        let progress = progress(for: dragState, in: scope)
        let dy = -selectedRow * CalendarConfigs.rowHeight
        if scope == .month {
            return dy * progress
        } else {
            return dragState.isDragging ? dy * (1-progress) : 0
        }
    }
    
    static func progress(for dragState: DragState, in scope: CalendarScope) -> CGFloat {
        let translationY = dragState.dy/CalendarConfigs.maxTranslationY
        let progress = scope == .month ? max(min(-translationY, 1), 0) : min(max(translationY, 0), 1)
        return progress
    }
    
}
