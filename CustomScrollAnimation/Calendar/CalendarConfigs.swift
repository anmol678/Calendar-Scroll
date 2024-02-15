//
//  CalendarConfigs.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/14/24.
//

import SwiftUI

struct CalendarConfigs {
       
    let safeArea: EdgeInsets
    
    private var frameHeight: CGFloat {
        Self.calendarTitleViewHeight + Self.weekLabelHeight + 2 * Self.verticalPadding + topPadding
    }
    
    var minCalendarHeight: CGFloat {
        Self.minCalendarGridHeight + frameHeight
    }
    
    var maxCalendarHeight: CGFloat {
        Self.maxCalendarGridHeight + frameHeight
    }
    
    var topPadding: CGFloat {
        safeArea.top
    }
    
    static var maxTranslationY: CGFloat {
        maxCalendarGridHeight - minCalendarGridHeight
    }
    
    static var calendarTitleViewHeight: CGFloat {
        44.0
    }
    
    static var weekLabelHeight: CGFloat {
        20.0
    }
    
    static var rowHeight: CGFloat {
        38.0
    }
    
    static private var minCalendarGridHeight: CGFloat {
        rowHeight
    }
    
    static private var maxCalendarGridHeight: CGFloat {
        6 * rowHeight
    }
    
    static var verticalPadding: CGFloat {
        5.0
    }
    
    static var horizontalPadding: CGFloat {
        16.0
    }
    
}
