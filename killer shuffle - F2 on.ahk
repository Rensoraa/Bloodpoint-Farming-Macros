#Requires AutoHotkey v2+
#Include Lib\common.ahk

setTrayIcon("icons/shuffle.ico")

; Dances forward and backwards in place, maintaining chase with survivors.
; Stops automatically if DBD loses focus or any of WASD are pressed.

IsSDown := false
IsWDown := false

; Start dancing
#HotIf WinActive(dbdWinTitle)
~F2::
{
    global
    IsEnabled := true
    loop {
        if (!IsEnabled)
            break

        holdKey("w", 100, &IsWDown)
        holdKey("s", 100, &IsSDown)
    }
}

holdKey(key, holdTime, &isKeyDown) {
    global
    ; If DBD loses focus, stop. Don't spam "wswsws" to other windows.

    if (!dbdWindow.isActive()) {
        disable()
        return
    }
    if (!IsEnabled)
        return

    ; Send the key down event
    SendInput("{" key " down}")
    isKeyDown := true
    Sleep(holdTime)  ; Hold the key down for the specified time

    if (!IsEnabled)
        return
    ; Reset key state and send key up event
    isKeyDown := false
    SendInput("{" key " up}")
}

; WASD key down handlers with pass-through
; WS need special handling.
; For example, we do not want to send W up if the user starts holding W.
~w::
{
    disable()
    resetS()
}
~s::
{
    disable()
    resetW()
}
~a::
~d::
{
    disable()
    resetW()
    resetS()
}

resetW() {
    global
    if (IsWDown) {
        SendInput("{w up}")
        IsWDown := false
    }
}
resetS() {
    global
    if (IsSDown) {
        SendInput("{s up}")
        IsSDown := false
    }
}
disable() {
    global
    IsEnabled := false
}
