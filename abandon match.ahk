#Requires AutoHotkey v2+
/*
Uses the Abandon Match feature as soon as available.

Requirements:
- Looks for pure white and black pixels of text.
  Reshade filters that make them off-white/black will cause this to fail.
*/
#HotIf WinActive(dbdWinTitle)
#Include Lib/common.ahk

setTrayIcon("icons/esc.ico")

SetTimer(CheckForAbandon, 500)

~^+a::
{
    abandonMatch()
}

CheckForAbandon() {
    global
    if (!WinActive(dbdWinTitle)) {
        return
    }

    if (isAbandonEscapeOptionVisible()) {
        start := A_TickCount

        abandonMatch()

        abandonTookMs := A_TickCount - start
        logger.info("Abandoning match took " . abandonTookMs . " ms")
    }
}

abandonMatch() {
    ; Full process of abandoning the match.
    Send("{ESC}")

    doWithRetriesUntil("doNothing", "isSettingsOpen")
    doWithRetriesUntil("clickSettingsAbandonButton", "isAbandonConfirmOpen")

    clickFinalAbandonButton()
}

clickSettingsAbandonButton() {
    ; Abandon button in the bottom right of the settings page
    scaled.click(2400, 1330)
}

clickFinalAbandonButton() {
    ; Final abandon button
    ; It loads in lower on the screen and drifts up.
    ; We'll aim towards the bottom in case it's clickable then.
    scaled.click(1844, 1067)
}
