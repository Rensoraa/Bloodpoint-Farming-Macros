#Requires AutoHotkey v2.0
#Include Lib\common.ahk
#HotIf WinActive(dbdWinTitle)
setTrayIcon("icons\space.ico")

/**
 * Holding space will spam the space bar.
 * 
 * Useful for:
 * - blowing up gens quickly
 * - hooking survivors as soon as possible
 * - adding years of life to your keyboard's space bar
 */

spaceHeld := false

~$*Space:: {
    global
    spaceHeld := true
    Sleep 200
    while spaceHeld {
        Send "{Space}"
        Sleep 100
    }
}

~$*Space Up:: {
    global
    spaceHeld := false
}
