#Include Lib\test_includes.ahk
#Include AutoUpdateTests.ahk
#Include AutospenderTests.ahk
#Include PregameTests.ahk
#Include QTests.ahk
#Include SettingsTests.ahk
#Include TallyTests.ahk

Yunit
    .Use(YunitJUnit, YunitOutputDebug, YunitStdOut, YunitExitOnTestFailure)
    .Test(
        AutoSpenderTests,
        AutoUpdateTests,
        PregameTests,
        QTests,
        SettingsTests,
        TallyTests,
    )