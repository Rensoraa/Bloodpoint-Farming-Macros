#Requires AutoHotkey v2+
#Include Lib\common.ahk
setTrayIcon("icons/q.ico")

/**
 * Uses the anniversary invitation as soon as it's available.
 */
pollInterval := 200

checkQ() {
    if WinActive(dbdWinTitle) and isQVisible() {
        logger.info("Pressing Q.")
        
        Send("{q down}")
        Sleep(50)
        Send("{q up}")
    }
}
SetTimer(checkQ, pollInterval)
