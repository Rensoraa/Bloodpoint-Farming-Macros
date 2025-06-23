#Requires AutoHotkey v2+
#Include ..\Lib\Gdip_All.ahk
#Include ..\Lib\common.ahk
#Include Lib\bench.ahk

Persistent(0)

validMarker := Integer("0x0b8b6c")
vTooLow := Integer("0x182132")
satTooLow := Integer("0x8c919a")

bench(() => Bloodweb.isTealMarker(vTooLow), "value too low")
bench(() => Bloodweb.isTealMarker(satTooLow), "sat too low")
bench(() => Bloodweb.isTealMarker(validMarker), "valid marker")
