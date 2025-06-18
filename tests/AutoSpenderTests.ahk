#Requires AutoHotkey v2.0

#Include Lib\test_includes.ahk
#Include Lib\fakes.ahk
#Include ..\Lib\Gdip_All.ahk
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
    
}

assertBloodwebLevel(expectedLevel, screenshotPath) {
    pBitmap := setupFakeWindow(screenshotPath)
    level := getBloodwebLevel()
    Gdip_DisposeImage(pBitmap)
    Yunit.Assert(level == expectedLevel, "level=" level " expected=" expectedLevel)
}
