#Requires AutoHotkey v2.0

#Include Lib\test_includes.ahk
#Include Lib\fakes.ahk
#Include ..\Lib\Gdip_All.ahk
#Include ..\Lib\bloodweb.ahk
#Include ..\Lib\dbd.ahk
#Include ..\Lib\scaling.ahk

if (A_ScriptFullPath = A_LineFile)
    Yunit
        .Use(YunitJUnit, YunitOutputDebug, YunitStdOut, YunitExitOnTestFailure)
        .Test(AutoSpenderTests)

class AutoSpenderTests {
    __New() {
        this.pToken := Gdip_Startup()
    }

    __Delete() {
        Gdip_Shutdown(this.pToken)
    }

    test_getBloodwebLevel_Level49_1440() => assertFor("bloodweb\bloodweb_1440_level32.png", () => getBloodwebLevel() == 32)
    test_getBloodwebLevel_Level21_1080() => assertFor("bloodweb\bloodweb_1080_level20.png", () => getBloodwebLevel() == 20)

    test_getBloodwebFull() {
        assertMarkers(nodes) {
            for node in nodes {
                teal := node.bottomLeft
                c := coords.getColor(teal)
                Yunit.Assert(Bloodweb.isTealMarker(c), "color=" Format("{:06X}", c) " coords=(" teal.x ", " teal.y ")")
            }
            return true
        }
        assertFor("bloodweb\bloodweb_full_1440.png", () => assertMarkers.Bind(Bloodweb.fromHeight(1440).all))
    }

    test_isMarked() => assertFor("bloodweb\1440\laurie.png", () => countBloodwebItems() = 3)

    test_isMarked_quentin() => assertFor("bloodweb\1440\quentin.png", () => countBloodwebItems() = 1)

    test_isLoaded_yes_1080() => assertFor("bloodweb\1080\loaded.png", () => Bloodweb.isLoaded())
    test_isLoaded_no_1080() => assertFor("bloodweb\1080\loading.png", () => !Bloodweb.isLoaded())

    test_isTealMarker() {
        for c in ["169679", "0b8b6c", "09896a", "008b69", "13FFD9"]
            Yunit.Assert(Bloodweb.isTealMarker(Integer("0x" c)), "0x" c)

        for c in [
            "000000", "ffffff",
            "010101", "fefefe",
            "0000ff", "ff0000", "00ff00"
            "7d8986", "021712",
        ]
            Yunit.Assert(!Bloodweb.isTealMarker(Integer("0x" c)), c)
    }

    test_isBlueMarker() {
        for c in ["0100f7"]
            Yunit.Assert(Bloodweb.isBlueMarker(Integer("0x" c)), "0x" c)

        for c in [
            "000000", "ffffff",
            "010101", "fefefe",
            "ff0000", "00ff00"
            "7d8986", "021712",
        ]
            Yunit.Assert(!Bloodweb.isBlueMarker(Integer("0x" c)), c)
    }

    test_isBloodwebError() => assertFor("bloodweb\bloodweb_error.png", () => Bloodweb.isBloodwebError())

}

assertBloodwebLevel(expectedLevel, screenshotPath) {
    pBitmap := setupFakeWindow(screenshotPath)
    level := getBloodwebLevel()
    Gdip_DisposeImage(pBitmap)
    Yunit.Assert(level == expectedLevel, "level=" level " expected=" expectedLevel)
}

countBloodwebItems() {
    c := 0
    bw := Bloodweb.fromHeight(dbdWindow.height)
    for node in bw.all {
        teal := coords.getColor(node.bottomLeft)
        blue := coords.getColor(node.bottomRight)
        if Bloodweb.isTealMarker(teal) and Bloodweb.isBlueMarker(blue)
            c += 1
    }
    return c
}
