#Requires AutoHotkey v2.0

#Include logging.ahk

isMouseBlocked := false

/**
 * Blocks or unblocks the mouse.
 * 
 * @returns whether the mouse was blocked previously
 */
setMouseBlocked(shouldBlock := true) {
    global isMouseBlocked
    wasBlocked := isMouseBlocked

    if shouldBlock != isMouseBlocked {
        BlockInput(shouldBlock ? "MouseMove" : "MouseMoveOff")
        ; Hotkey("LButton", BlockClick, shouldBlock ? "On" : "Off") ; This clobbers other LButton handlers. Don't do this!
        isMouseBlocked := shouldBlock
    }

    return wasBlocked
}

/**
 * Runs the function with user mouse input blocked.
 * 
 * After the function completes, the user's mouse control will be restored
 * to whatever state it was in before the function.
 * 
 * @param f function
 */
withMouseBlocked(f) {
    ; The `local` is important here or else the finally block will not close over the value of it.
    oldValue := setMouseBlocked(true)
    try {
        f.Call()
    } finally {
        setMouseBlocked(oldValue)
    }
}

BlockClick(*) => ""
