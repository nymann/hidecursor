import CoreGraphics
import CoreFoundation
import Dispatch

// Private CGS API: setting "SetsCursorInBackground" on our connection lets
// CGDisplayHideCursor work from a background daemon, which the public API
// won't do on its own.
typealias CGSConnectionID = Int32

@_silgen_name("_CGSDefaultConnection")
func _CGSDefaultConnection() -> CGSConnectionID

@_silgen_name("CGSSetConnectionProperty")
func CGSSetConnectionProperty(_ cid: CGSConnectionID, _ targetCID: CGSConnectionID, _ key: CFString, _ value: CFTypeRef) -> Int32

protocol IdleObserver: AnyObject {
    func idleStateDidChange(isIdle: Bool)
}

final class Cursor: IdleObserver {
    private(set) var isHidden = false

    init() {
        let cid = _CGSDefaultConnection()
        // 0 == kCFStringEncodingMacRoman; constant lives in Foundation's
        // overlay which we don't import. Pure ASCII works fine.
        let key = CFStringCreateWithCString(nil, "SetsCursorInBackground", 0)!
        _ = CGSSetConnectionProperty(cid, cid, key, kCFBooleanTrue)
    }

    func hide() {
        guard !isHidden else { return }
        CGDisplayHideCursor(CGMainDisplayID())
        isHidden = true
    }

    func show() {
        guard isHidden else { return }
        CGDisplayShowCursor(CGMainDisplayID())
        isHidden = false
    }

    func idleStateDidChange(isIdle: Bool) {
        if isIdle { hide() } else { show() }
    }
}

final class IdleMonitor {
    let threshold: Double
    private struct WeakObserver { weak var observer: IdleObserver? }
    private var observers: [WeakObserver] = []
    private var timer: DispatchSourceTimer?
    private var wasIdle = false
    private static let anyInputEventType = CGEventType(rawValue: 0xFFFFFFFF)!

    init(threshold: Double) {
        self.threshold = threshold
    }

    func subscribe(_ observer: IdleObserver) {
        observers.append(WeakObserver(observer: observer))
    }

    func start(pollInterval: Double = 0.5) {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now(), repeating: .milliseconds(Int(pollInterval * 1000)))
        t.setEventHandler { [weak self] in self?.tick() }
        t.resume()
        timer = t
    }

    private func tick() {
        let idle = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: IdleMonitor.anyInputEventType)
        let nowIdle = idle >= threshold
        guard nowIdle != wasIdle else { return }
        wasIdle = nowIdle
        observers.forEach { $0.observer?.idleStateDidChange(isIdle: nowIdle) }
    }
}

let cursor = Cursor()
let monitor = IdleMonitor(threshold: 2.0)
monitor.subscribe(cursor)
monitor.start()

CFRunLoopRun()
