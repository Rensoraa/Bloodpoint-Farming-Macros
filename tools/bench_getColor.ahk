#Requires AutoHotkey v2+
#Include ..\Lib\Gdip_All.ahk
#Include ..\Lib\common.ahk
#Include Lib\bench.ahk
Persistent(0)

pToken := Gdip_Startup()
x := 0
y := 0
c := Coords2K(0, 0)

points := 130

benchPoints(f, label) {
    doForAllPoints() {
        loop points {
            f.Call()
        }
    }
    bench(() => doForAllPoints(), label)
}

; Bloodweb region
width := Integer((1122 - 260) / 1920 * 2560)
height := Integer((990 - 150) / 1080 * 1440)
oneScreenshot() {
    image := PBitmapImage.of(0, 0, width, height)
    loop points {
        image.getColor(x, y)
    }
    image.dispose()
}


benchPoints(() => PixelGetColor(x, y) & 0xFFFFFF, "PixelGetColor")
benchPoints(() => ops.getColor(x, y), "ops")
benchPoints(() => scaled.getColor(x, y), "scaled")
benchPoints(() => coords.getColor(c), "coords")
bench(oneScreenshot, "oneScreenshot")

Gdip_Shutdown(pToken)