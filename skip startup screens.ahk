#Requires AutoHotkey v2+
#Include Lib\common.ahk

; Skips DBD startup screens until the [ESC] text on main menu is visible.

; Set showToolTip to false if you don't want tooltip status reports.
showToolTip := true

setTrayIcon("icons/dbd-logo.ico")

SetTitleMatchMode(1) ; Exact title match
; CoordMode("Pixel", "Screen")

isDbdRunning := false
SetTimer(CheckIfDbdRunning, 5000)

CheckIfDbdRunning() {
    global
    if WinExist(dbdWinTitle) {
        if (!isDbdRunning) {
            logger.info("DBD found. Starting check loop.")
            startTime := A_TickCount
            isDbdRunning := true
            SetTimer(ClickThroughScreens, 500)
        }
    } else {
        isDbdRunning := false
    }
}

ClickThroughScreens() {
    waitedTooLong := A_TickCount - StartTime > 90000

    if (isDbdFinishedLoading() || waitedTooLong) {
        ; Finished/Loaded
        SetTimer(ClickThroughScreens, 0)

        dbdLoadTimeSeconds := elapsedSeconds() ; set global var for user retrieval later.
        statusUpdate("DBD started in " . dbdLoadTimeSeconds . " seconds.")
        SetTimer(clearToolTip, 2000)
    } else {
        ; Not loaded/keep clicking...
        ; statusUpdate("Clicking through startup screens (" . elapsedSeconds() . " sec)...")
        ControlClick(, dbdWinTitle)
    }
}

clearToolTip() {
    if (showToolTip)
        ToolTip()
}

elapsedSeconds() {
    elapsedMs := A_TickCount - startTime
    return Floor(elapsedMs / 1000)
}

statusUpdate(msg) {
    logger.info(msg)
    if (showToolTip)
        ToolTip(msg)
}
