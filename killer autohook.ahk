#Requires AutoHotkey v2+
#Include Lib\common.ahk

setTrayIcon("icons/hook.ico")

; This macro hooks a carried survivor whenever possible,
; adding years of life to your keyboard's spacebar.

SetTimer(HookIfPossible, 200)

HookIfPossible() {
    if (WinActive(dbdWinTitle) and isHookSpaceOptionAvailable()) {
        Send("{Space}")
    }
}
