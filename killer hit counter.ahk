#Requires AutoHotkey v2+
#Include Lib\common.ahk
#HotIf WinActive(dbdWinTitle)

; Counts how many times M1 was pressed repeatedly with a debouce time of ~STBFL=8.
; Useful track the number of self-heal rotations in Reactive Healing builds.
;
; Hides the counter if there are no M1s for the specified duration.
; Usually this means that the rective portion is done.
HideTimerAfterNoHitsForMs := 15000

SendMode("Input")
setTrayIcon("icons/reactive.ico")

counter := 0
lastHitTimestamp := 0

; Create GUI
myGui := Gui("+LastFound +AlwaysOnTop +ToolWindow -Caption +Disabled", "M1 Counter")
myGui.BackColor := "0"  ; Set background to black
myGui.SetFont("cWhite s60 Bold")
counterText := myGui.Add("Text", "vCounterText w300 BackgroundTrans", 0)
WinSetTransColor(0)  ; set black as transparent

~^-:: {
    if (counter > 0)
        setCounter(counter - 1)
}

~^=:: {
    setCounter(counter + 1)
}
~^r:: {
    global
    setCounter(0)
    lastHitTimestamp := 0 ; Allow M1 to register immediately.
}

~LButton::
{
    global
    now := A_TickCount
    millisSinceLastHit := now - lastHitTimestamp
    ; STBFL=8 is ~2000 ms
    if (millisSinceLastHit > 2000) {
        lastHitTimestamp := now
        setCounter(counter + 1)
    }
}

setCounter(value) {
    global counter
    logger.info("Setting counter to " value)
    counter := value
    if (value = 0) {
        myGui.Hide()
    } else {
        myGui.Show("x70 y400 NoActivate")
        SetTimer(ResetCounter, HideTimerAfterNoHitsForMs)
        counterText.Value := counter
    }
}

ResetCounter() {
    SetTimer(, 0)
    setCounter(0)
    logger.info("Resetting counter because no hits within " HideTimerAfterNoHitsForMs ".")
}
