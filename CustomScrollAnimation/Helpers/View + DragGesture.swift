//
//  View + DragGesture.swift
//  CustomScrollAnimation
//
//  Created by Anmol Jain on 2/14/24.
//

import SwiftUI

struct DragGestureViewModifier: ViewModifier {
    typealias Callback = () -> Void
    
    @GestureState private var dragState: DragState = .inactive
    @State var gestureState: GestureStatus = .idle

    @State var startingOffsetY: CGFloat = 0.0

    var onStart: Callback?
    var onUpdate: ((CGFloat) -> Void)?
    var onEnd: ((DragGesture.Value) -> Void)?
    var onCancel: Callback?

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 35.0, coordinateSpace: .global)
                    .updating($dragState) { gesture, dragState, _ in
                        dragState = .dragging(dy: gesture.translation.height)
                    }
                    .onChanged(onDragChange(_:))
                    .onEnded(onDragEnded(_:))
            )
            .onChange(of: gestureState) { oldValue, state in
                guard state == .started else { return }
                gestureState = .active
            }
            .onChange(of: dragState.isDragging) { oldValue, value in
                if value, gestureState != .started {
                    gestureState = .started
                    onStart?()
                    startingOffsetY = dragState.dy
                } else if !value, gestureState != .ended {
                    gestureState = .cancelled
                    onCancel?()
                    startingOffsetY = 0
                }
            }
    }

    func onDragChange(_ value: DragGesture.Value) {
        guard gestureState == .started || gestureState == .active else { return }
        
        onUpdate?(value.translation.height - startingOffsetY)
    }

    func onDragEnded(_ value: DragGesture.Value) {
        gestureState = .ended
        onEnd?(value)
        startingOffsetY = 0
    }

    enum GestureStatus: Equatable {
        case idle
        case started
        case active
        case ended
        case cancelled
    }
}

extension View {
    func onDragGesture(
        onStart: DragGestureViewModifier.Callback? = nil,
        onUpdate: ((CGFloat) -> Void)? = nil,
        onEnd: ((DragGesture.Value) -> Void)? = nil,
        onCancel: DragGestureViewModifier.Callback? = nil
    ) -> some View {
        modifier(DragGestureViewModifier(onStart: onStart, onUpdate: onUpdate, onEnd: onEnd, onCancel: onCancel))
    }
}
