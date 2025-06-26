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
    test_getBloodwebLevel_Level20_1080() => assertFor("bloodweb\bloodweb_1080_level20.png", () => getBloodwebLevel() == 20)

    test_getBloodwebFull() {
        assertMarkers(nodes) {
            for node in nodes {
                teal := node.bottomLeft
                c := coords.getColor(teal)
                Yunit.Assert(Bloodweb.isTealMarker(c), "color=" Format("{:06X}", c) " coords=(" teal.x ", " teal.y ")")
            }
            return true
        }
        assertFor("bloodweb\bloodweb_full_1440.png", () => assertMarkers(Bloodweb.fromHeight(1440).all))
    }

    test_getBloodweb_pink() {
        assertMarkers() {
            nodes := Bloodweb.fromHeight(1440).all
            count := 0
            for node in nodes {
                teal := node.bottomLeft
                if Bloodweb.isTealMarker(coords.getColor(node.bottomLeft)) and Bloodweb.isBlueMarker(coords.getColor(node.bottomRight)) {
                    count += 1
                    c := node.topLeft
                    color := coords.getColor(node.topLeft)
                    p := Bloodweb.markerPriority(color)
                    Yunit.Assert(p = 1, "color=" Format("{:06X}", color) " coords=(" c.x ", " c.y ")")
                }
            }
            Yunit.Assert(count >= 26)
            return true
        }
        assertFor("bloodweb\1440\nodes-pink.png", () => assertMarkers())
    }

    test_getBloodweb_quentin2() {
        assertMarkers() {
            nodes := Bloodweb.fromHeight(1440).all
            m := Map()
            for node in nodes {
                teal := node.bottomLeft
                if Bloodweb.isTealMarker(coords.getColor(node.bottomLeft)) and Bloodweb.isBlueMarker(coords.getColor(node.bottomRight)) {
                    c := node.topLeft
                    logger.info("topLeft: " c.toString())
                    color := coords.getColor(node.topLeft)
                    p := Bloodweb.markerPriority(color)
                    m[p] := m.Has(p) ? m[p] + 1 : 1
                }
            }
            Yunit.Assert(m[2] = 1)
            Yunit.Assert(m[5] = 2)
            return true
        }
        assertFor("bloodweb\1440\quentin2.png", () => assertMarkers())
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

    test_isBulkSpendVisible1() => assertFor("bloodweb\1440\laurie.png", () => Bloodweb.isBulkSpendVisible())
    test_isBulkSpendVisible2() => assertFor("bloodweb\1440\quentin.png", () => Bloodweb.isBulkSpendVisible())
    test_isBulkSpendOkVisible() => assertFor("bloodweb\1440\bulk-done.png", () => Bloodweb.isBulkSpendOkVisible())

    test_isBulkSpendConfirmButtonVisible() => assertFor("bloodweb\1440\bulk-prompt.png", () => Bloodweb.isBulkSpendConfirmButtonVisible())

    test_isP100_Yes() => assertFor("bloodweb\bloodweb_full_1440.png", () => Bloodweb.isP100())
    test_isP100_No() => assertFor("bloodweb\1440\quentin.png", () => !Bloodweb.isP100())
    test_isP100_1080_Yes() => assertFor("bloodweb\1080\p100.png", () => Bloodweb.isP100())
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
