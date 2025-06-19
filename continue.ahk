#Requires AutoHotkey v2+

#Include Lib\common.ahk

SetTimer(CheckContinueButton, 200)

setTrayIcon("icons\tally.ico")

CheckContinueButton() {
    if !WinActive(dbdWinTitle)
        return

    if isTallyScreen() {
        coords.click(tallyContinueButtonRed)
    }
}
