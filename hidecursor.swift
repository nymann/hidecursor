import Cocoa
import CoreGraphics

let idleThreshold: TimeInterval = 2.0
var hidden = false
var lastMove = Date()

NSEvent.addGlobalMonitorForEvents(
    matching: [.mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel]
) { _ in
    lastMove = Date()
    if hidden {
        CGDisplayShowCursor(CGMainDisplayID())
        hidden = false
    }
}

Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
    if !hidden && Date().timeIntervalSince(lastMove) > idleThreshold {
        CGDisplayHideCursor(CGMainDisplayID())
        hidden = true
    }
}

NSApplication.shared.run()
