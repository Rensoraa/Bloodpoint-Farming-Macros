#Requires AutoHotkey v2+
#Include Lib/common.ahk
#HotIf WinActive(dbdWinTitle)
setTrayIcon("icons/fps-120.ico")

; Set 30 FPS
F3::
{
    selectFpsOption(1760, 778)
    setTrayIcon("icons/fps-30.ico")
}

; Set 120 FPS
F4::
{
    ; 120 FPS option
    selectFpsOption(1778, 1084)
    setTrayIcon("icons/fps-120.ico")
}

; Selects an option from the FPS dropdown at the specified pixel coordinates
; relative to a 1440p resolution. These will be scaled for non-1440p resolutions.
selectFpsOption(x, y) {
    global settingFpsTookMs
    start := A_TickCount

    openSettingsGraphicsFpsMenu()
    scaled.click(x, y)

    ; Wait for the FPS menu to close before hitting ESC.
    ; Hitting ESC too fast will cause the FPS option to not be saved.
    doWithRetriesUntil("doNothing", "isSettingsGraphicsFpsMenuClosed")

    closeSettings()

    settingFpsTookMs := A_TickCount - start
    logger.info("Setting FPS took " . settingFpsTookMs . " ms")
}

openSettingsGraphicsFpsMenu() {
    ; Open Settings
    Send("{ESC}")

    ; Sometimes the game lags with black screen when opening menu first time.
    ; Wait for the screen to open.
    ; Note that the [ ESC ] (295, 1350) button looks pure white, but is slightly off white!
    doWithRetriesUntil("doNothing", "isSettingsOpen")

    ; Select "Graphics" tab
    doWithRetriesUntil("selectGraphicsTab", "isSettingsGraphicsTabSelected")

    ; Open FPS dropdown
    doWithRetriesUntil("openFpsMenu", "isSettingsGraphicsFpsMenuOpen")
}

isSettingsGraphicsFpsMenuClosed() => !isSettingsGraphicsFpsMenuOpen()

closeSettings() {
    Send("{ESC}")
}

selectGraphicsTab() {
    scaled.click(988, 94)
}

openFpsMenu() {
    ; Center of FPS option
    scaled.click(1350, 938)
}
