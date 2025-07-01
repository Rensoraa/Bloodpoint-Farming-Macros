#Requires AutoHotkey v2+

#Include logging.ahk
#Include blocking.ahk
#Include constants.ahk

CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"

dbdWindow := DbdWindowOps()
ops := WindowOps()
scaled := ScaledOps()

class DbdWindowOps {
    _width := 0
    _height := 0
    checkScale() {
        static lastCheck := 0

        if (A_TickCount - lastCheck > 100) {
            ; WinGetPos, winX, winY, DbdWidth, DbdHeight, DeadByDaylight
            ; WinGetPos does not return the client area height while windowed, regardless of CoordMode, Client.
            try {
                hwnd := WinGetID(dbdWinTitle)
                rect := Buffer(16, 0)
                DllCall("GetClientRect", "ptr", hwnd, "ptr", rect.Ptr)

                this._width := NumGet(rect, 8, "Int")
                this._height := NumGet(rect, 12, "Int")
                logger.debug("DBD window size: " this._width "x" this._height)
            } catch TargetError {
                logger.debug("DeadByDaylight window not found.")
            }
            lastCheck := A_TickCount
        }
    }
    width => (this.checkScale(), this._width)
    height => (this.checkScale(), this._height)
    isActive() => WinActive(dbdWinTitle)
}

/**
 * Wrapper around default operations so we can DI fakes for testing.
 */
class WindowOps {
    click(x, y, options := "") {
        withMouseBlocked(() => Click(x " " y " " options))
    }

    mouseMove(x, y) => MouseMove(x, y)
    getColor(x, y) => (PixelGetColor(x, y) & 0xFFFFFF)
}

/**
 * Scales the coordinates of the operations to the current window size.
 */
class ScaledOps {
    baseWidth := 2560
    baseHeight := 1440

    scaleX(x) => Round(x * dbdWindow.width / this.baseWidth)
    scaleY(y) => Round(y * dbdWindow.height / this.baseHeight)

    click(x, y, options := "") {
        scaledX := this.scaleX(x)
        scaledY := this.scaleY(y)

        logger.trace("scaled.click(" x "=>" scaledX ", " y "=>" scaledY ") " options)
        return ops.click(scaledX, scaledY, options)
    }

    getColor(x, y) {
        scaledX := this.scaleX(x)
        scaledY := this.scaleY(y)

        color := ops.getColor(scaledX, scaledY)

        logger.trace("getColor(" x ", " y ") => (" scaledX ", " scaledY ")=" Format("{:06X}", color))

        return color
    }

    mouseMove(x, y) {
        scaledX := this.scaleX(x)
        scaledY := this.scaleY(y)

        ops.mouseMove(scaledX, scaledY)
    }
}
