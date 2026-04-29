import Cocoa

// Private CGS API: setting "SetsCursorInBackground" on our connection lets
// CGDisplayHideCursor work from a background daemon, which the public API
// won't do on its own.
typealias CGSConnectionID = Int32

@_silgen_name("_CGSDefaultConnection")
func _CGSDefaultConnection() -> CGSConnectionID

@_silgen_name("CGSSetConnectionProperty")
func CGSSetConnectionProperty(_ cid: CGSConnectionID, _ targetCID: CGSConnectionID, _ key: CFString, _ value: CFTypeRef) -> Int32

func setCursorHidden(_ hide: Bool) {
    let cid = _CGSDefaultConnection()
    _ = CGSSetConnectionProperty(cid, cid, "SetsCursorInBackground" as CFString, kCFBooleanTrue)
    if hide { CGDisplayHideCursor(CGMainDisplayID()) }
    else    { CGDisplayShowCursor(CGMainDisplayID()) }
}

let idleThreshold: TimeInterval = 2.0
var lastPos = NSEvent.mouseLocation
var lastChange = Date()
var hidden = false

Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
    let p = NSEvent.mouseLocation
    if p != lastPos {
        lastPos = p
        lastChange = Date()
        if hidden { setCursorHidden(false); hidden = false }
    } else if !hidden && Date().timeIntervalSince(lastChange) > idleThreshold {
        setCursorHidden(true); hidden = true
    }
}

RunLoop.main.run()
