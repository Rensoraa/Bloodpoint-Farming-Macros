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
        .Test(QTests)

class QTests {
    __New() {
        this.pToken := Gdip_Startup()
    }

    __Delete() {
        Gdip_Shutdown(this.pToken)
    }

    test1080() => assertFor("match\q1080.png", isQVisible)
    test1440() => assertFor("match\q1440.png", isQVisible)
    test1440Dpad() => assertFor("match\q1440dpad.png", isQVisible)
    test664() => assertFor("match\q664.png", isQVisible)
    test70procent() => assertFor("match\q1080(70% hud scale).png", isQVisible)
}
