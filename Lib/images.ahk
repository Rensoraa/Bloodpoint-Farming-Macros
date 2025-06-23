#Requires AutoHotkey v2.0

#Include ..\Lib\Gdip_All.ahk
#Include ..\Lib\constants.ahk

pToken := Gdip_Startup()

class PBitmapImage {
    __New(pBitmap) {
        width := 0, height := 0, stride := 0, scan0 := 0, bitmapData := Buffer(64)

        ; https://chatgpt.com/share/685670be-6a20-8010-ac87-8f904568c1ca
        Gdip_GetImageDimensions(pBitmap, &width, &height)
        Gdip_LockBits(pBitmap, 0, 0, width, height, &stride, &scan0, &bitmapData)
        this.pBitmap := pBitmap
        this.bitmapData := bitmapData
        this.stride := stride
        this.scan0 := scan0
        this.width := width
        this.height := height
    }

    getColor(x, y) {
        if (x < 0 || y < 0)
            throw Error("Coordinates must be non-negative")
        if x >= this.width or y >= this.height
            throw Error("(" x ", " y ") out of bounds for " this.width "x" this.height)

        offset := y * this.stride + x * 4
        pixel := NumGet(this.scan0 + offset, "UInt")  ; Format: ARGB
        return pixel & 0xFFFFFF
    }

    dispose() {
        if this.pBitmap != 0 {
            data := this.bitmapData
            Gdip_UnlockBits(this.pBitmap, &data)
            Gdip_DisposeImage(this.pBitmap)
            this.pBitmap := 0
        }
    }

    /**
     * Capture a section of the DBD window.
     * 
     * Performance greatly depends on number of size of the region captured.
     * - PixelGetColor takes 3.4 ms
     * - PBitmapImage takes 3.7 ms for 1x1 to ~100x100 regions.
     * - PBitmapImage takes 13.8 ms for a 1000x1000 region or the equivalent of ~4 PixelGetColor calls.
     * 
     * @returns PBitmapImage of the rectangle 
     */
    static of(x, y, w, h) {
        hwnd := WinExist(dbdWinTitle)
        ; There is no Gdip function to capture a window, so
        ; we have to find the window client area relative to the screen.
        pt := Buffer(8, 0)
        DllCall("ClientToScreen", "ptr", hwnd, "ptr", pt)
        wx := NumGet(pt, 0, "int")
        wy := NumGet(pt, 4, "int")
        return PBitmapImage(Gdip_BitmapFromScreenDelegate(wx + x, wy + y, w, h))
    }
}

Gdip_BitmapFromScreenDelegate := (x, y, w, h) => Gdip_BitmapFromScreen(x "|" y "|" w "|" h)

/**
 * Screenshots a sub-section of the screen.
 */
class Subscreenshot {

    __New(x, y, img) {
        this.x := x
        this.y := y
        this.img := img
    }

    static of(x, y, w, h) => Subscreenshot(x, y, PBitmapImage.of(x, y, w, h))

    /**
     * Gets the color using coordinates relative to the whole DBD window.
     */
    getColorLiteral(x, y) => this.img.getColor(x - this.x, y - this.y)

    /**
     * Gets the color using coordinates relative to the whole DBD window at some arbitrary scale.
     * The coords will be rescaled to the active window.
     */
    getColor(point) {
        scaledX := point.scaledX()
        scaledY := point.scaledY()

        color := this.getColorLiteral(scaledX, scaledY)

        logger.trace("getColor(" point.x ", " point.y ") => (" scaledX ", " scaledY ")=" Format("{:06X}", color))

        return color
    }

    dispose() => this.img.dispose()
}
