#Requires AutoHotkey v2.0

#Include Lib\test_includes.ahk
#Include Lib\fakes.ahk
#Include ..\Lib\Gdip_All.ahk
#Include ..\Lib\dbd.ahk
#Include ..\Lib\scaling.ahk

if (A_ScriptFullPath = A_LineFile)
    Yunit
        .Use(YunitJUnit, YunitOutputDebug, YunitStdOut, YunitExitOnTestFailure)
        .Test(PregameTests)

class PregameTests {
    __New() {
        this.pToken := Gdip_Startup()
    }

    __Delete() {
        Gdip_Shutdown(this.pToken)
    }

    test_isReadiedUp_No1440() => assertFor("pregame\unready1440.png", () => !isReadiedUp())
    test_isReadiedUp_No1080() => assertFor("pregame\unready1080.png", () => !isReadiedUp())
    test_isReadiedUp_Yes1440() => assertFor("pregame\readiedUp1440.png", isReadiedUp.Bind())
    test_isReadiedUp_Yes1080() => assertFor("pregame\readiedUp1080.png", isReadiedUp.Bind())
    test_isReadiedUp_YesReshade1440() => assertFor("pregame\readiedUpReshade1440.png", isReadiedUp.Bind())
    test_isReadiedUp_YesReshade1080() => assertFor("pregame\readiedUpReshade1080.png", isReadiedUp.Bind())
    test_isReadiedUp_NoKiller1440() => assertFor("pregame\unreadyKiller1440.png", () => !isReadiedUp())
    test_isReadiedUp_YesKiller1440() => assertFor("pregame\readiedUpKiller1440.png", () => isReadiedUp())
    test_isReadiedUp_HoverReshade1440() => assertFor("pregame\unreadyHoverReshade1440.png", () => !isReadiedUp())

    test_isReadyButtonVisible_1440() => assertFor("pregame\unready1440.png", isReadyButtonVisible.Bind())
    test_isReadyButtonVisible_1080() => assertFor("pregame\unready1080.png", isReadyButtonVisible.Bind())
    test_isReadyButtonVisible_Reshade1440() => assertFor("pregame\unreadyReshade1440.png", isReadyButtonVisible.Bind())
    test_isReadyButtonVisible_Reshade1080() => assertFor("pregame\unreadyReshade1080.png", isReadyButtonVisible.Bind())
    test_isReadyButtonVisible_Hover1440() => assertFor("pregame\unreadyHover1440.png", isReadyButtonVisible.Bind())
    test_isReadyButtonVisible_HoverReshade1440() => assertFor("pregame\unreadyHoverReshade1440.png", isReadyButtonVisible.Bind())
    test_isReadyButtonVisible_Killer1440() => assertFor("pregame\unreadyKiller1440.png", isReadyButtonVisible.Bind())
}
