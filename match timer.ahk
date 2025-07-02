#SingleInstance Force
#Persistent
#NoEnv
SetBatchLines, -1
SetTimer, CheckMatchStart, 500
CoordMode, Pixel, Screen
CoordMode, ToolTip, Screen

startTime := 0
running := false
isLetterboxVisible := false

screenWidth := A_ScreenWidth
screenHeight := A_ScreenHeight
barHeight := Round(screenHeight * 0.055)  ; ~5.5% of screen

if (FileExist("icons/stopwatch.ico"))
    Menu, Tray, Icon, icons/stopwatch.ico

; GUI Setup
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, 1E1E1E
Gui, Font, s32 cFFFFFF, Consolas

; Add vertically centered timer display
; +0x200 = SS_CENTERIMAGE, centers text vertically within its control
Gui, Add, Text, vTimerDisplay x0 y0 w300 h90 Center BackgroundTrans +0x200 gDragWindow, 0:00

Gui, Show, x10 y10 w300 h90 NoActivate, DBD Stopwatch
SetTimer, UpdateTimer, 1000
Return

CheckMatchStart:
{
    blackTop := true
    blackBottom := true
    sampleCount := 5

    ; Sample multiple evenly spaced pixels from top and bottom bars
    Loop, %sampleCount%
    {
        x := Round(screenWidth * (A_Index / (sampleCount + 1)))

        PixelGetColor, topColor, %x%, % (barHeight // 2), RGB
        PixelGetColor, bottomColor, %x%, % (screenHeight - barHeight // 2), RGB

        if (topColor != 0x000000)
            blackTop := false
        if (bottomColor != 0x000000)
            blackBottom := false
    }

    ; Sample mid-left and mid-right to rule out the pure black screen scenario, e.g. loading screen
    centerY := screenHeight // 2
    PixelGetColor, leftCenterColor, 0, %centerY%, RGB
    PixelGetColor, rightCenterColor, % (screenWidth - 1), %centerY%, RGB

    centerIsBlack := leftCenterColor = 0x000000 && rightCenterColor = 0x000000

    if (!isLetterboxVisible
        && blackTop
        && blackBottom
        && !centerIsBlack) {

        ; Letterbox detected. Record it and prepare for them to be removed.
        isLetterboxVisible := true
        letterBoxFirstSighted := A_TickCount
        Return
    }

    if (isLetterboxVisible
        && !blackTop
        && !blackBottom
        && !centerIsBlack) {

        ; Letterbox just disappeared. Start the match.
        startTime := A_TickCount
        running := true

        isLetterboxVisible := false
    }
}
Return


UpdateTimer:
if (running) {
    elapsed := (A_TickCount - startTime) // 1000
    minutes := elapsed // 60
    seconds := Mod(elapsed, 60)
    formattedTime := minutes ":" SubStr("0" seconds, -1)
    GuiControl,, TimerDisplay, %formattedTime%
}
Return


; Make whole window draggable
DragWindow:
PostMessage, 0xA1, 2,,, A
Return

GuiClose:
ExitApp
