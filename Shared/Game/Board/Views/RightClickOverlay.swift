import AppKit
import SwiftUI
import SwiftChessCore

struct RightClickOverlay: NSViewRepresentable {
    let fieldSize: CGFloat
    let orientation: BoardOrientation
    let onHighlightSquare: (String) -> Void
    let onArrowDrawn: (String, String, AnnotationColor) -> Void

    func makeNSView(context: Context) -> RightClickView {
        RightClickView()
    }

    func updateNSView(_ nsView: RightClickView, context: Context) {
        nsView.fieldSize = fieldSize
        nsView.orientation = orientation
        nsView.onHighlightSquare = onHighlightSquare
        nsView.onArrowDrawn = onArrowDrawn
    }
}

class RightClickView: NSView {
    var fieldSize: CGFloat = 0
    var orientation: BoardOrientation = BoardOrientation(isFlipped: false)
    var onHighlightSquare: ((String) -> Void)?
    var onArrowDrawn: ((String, String, AnnotationColor) -> Void)?

    private var rightDragStartSquare: String?
    private var dragColor: AnnotationColor = .green
    private var isTrackingRightMouse = false
    private var eventMonitor: Any?

    override var isFlipped: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
        guard window != nil else { return }
        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.rightMouseDown, .rightMouseDragged, .rightMouseUp]
        ) { [weak self] event in
            return self?.handleRightMouse(event) ?? event
        }
    }

    isolated deinit {
        if let eventMonitor { NSEvent.removeMonitor(eventMonitor) }
    }

    private func handleRightMouse(_ event: NSEvent) -> NSEvent? {
        switch event.type {
        case .rightMouseDown:
            let point = convert(event.locationInWindow, from: nil)
            guard bounds.contains(point) else { return event }
            isTrackingRightMouse = true
            dragColor = Self.color(from: event.modifierFlags)
            rightDragStartSquare = squareName(at: point)
            return nil

        case .rightMouseDragged:
            return isTrackingRightMouse ? nil : event

        case .rightMouseUp:
            guard isTrackingRightMouse else { return event }
            isTrackingRightMouse = false
            let point = convert(event.locationInWindow, from: nil)
            let endSquare = squareName(at: point)
            if let startSquare = rightDragStartSquare, !startSquare.isEmpty {
                let target = endSquare.isEmpty ? startSquare : endSquare
                if startSquare == target {
                    DispatchQueue.main.async { self.onHighlightSquare?(startSquare) }
                } else {
                    let color = self.dragColor
                    DispatchQueue.main.async { self.onArrowDrawn?(startSquare, target, color) }
                }
            }
            rightDragStartSquare = nil
            return nil

        default:
            return event
        }
    }

    private static func color(from flags: NSEvent.ModifierFlags) -> AnnotationColor {
        if flags.contains(.shift) { return .red }
        if flags.contains(.option) { return .yellow }
        if flags.contains(.command) { return .blue }
        return .green
    }

    private func squareName(at point: CGPoint) -> String {
        let file = orientation.logicalFile(x: point.x, fieldSize: fieldSize)
        let row = orientation.logicalRow(y: point.y, fieldSize: fieldSize)
        guard file >= 1, file <= 8, row >= 1, row <= 8 else { return "" }
        let fileChar = Character(UnicodeScalar(Int(("a" as UnicodeScalar).value) + file - 1)!)
        return "\(fileChar)\(row)"
    }
}
