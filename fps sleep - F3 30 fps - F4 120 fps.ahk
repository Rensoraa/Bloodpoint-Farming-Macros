#Requires AutoHotkey v2+
#Include Lib\common.ahk
#HotIf WinActive(dbdWinTitle)

; This macro much is slower than the default one,
; but does not depend on pixels being a specific color.
; This makes it much more likely to work with bizarre reshade filters.

; Set 30 FPS (Ctrl-)
F3::
{
    ; 30 FPS option
    selectFpsOption(1760, 778)
}

; Set 120 FPS (Ctrl+)
F4::
{
    ; 120 FPS option
    selectFpsOption(1778, 1084)
}

; Selects an option from the FPS dropdown at the specified pixel coordinates
; relative to a 1440p resolution. These will be scaled for non-1440p resolutions.
selectFpsOption(x, y) {
    start := A_TickCount

    openGraphicsSettings()

    scaled.click(x, y)

    closeSettings()

    global settingFpsTookMs := A_TickCount - start
}

openGraphicsSettings() {
    ; Open Settings
    Send("{ESC}")

    ; Sometimes the game lags with black screen when opening menu first time.
    ; Wait for the screen to open.
    Sleep(300)

    ; Select "Graphics" tab
    scaled.click(988, 94)
    Sleep(50)

    ; Open FPS dropdown
    scaled.click(1350, 938)
    Sleep(50)
}

closeSettings() {
    Send("{ESC}")
}
