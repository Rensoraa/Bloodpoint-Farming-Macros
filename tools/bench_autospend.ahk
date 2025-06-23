#Requires AutoHotkey v2+
#Include ..\Lib\Gdip_All.ahk
#Include ..\Lib\common.ahk
#Include ..\autospend - F6.ahk
#Include ..\tests\Lib\fakes.ahk
#Include Lib\bench.ahk

Persistent(0)
testDuration := 5000

; === Setup ===
pToken := Gdip_Startup()
pBitmap := setupFakeWindow(A_ScriptDir "..\..\tests\screenshots\bloodweb\1440\no-tags.png")
ss := Subscreenshot(0, 0, pBitmap)
setBloodwebSize()

; === Benchmarks ===
bench(measured)


; === Code under test ===
measured() {
    buyItemsAtPoints(bw.outerRing, 2, ss)
}

Gdip_DisposeImage(pBitmap)
Gdip_Shutdown(pToken)