#Requires AutoHotkey v2.0

#Include logging.ahk

class Stopwatch {
    start := A_TickCount
    __New(label) {
        this.label := label
    }
    report() => logger.info(this.label " took " (A_TickCount - this.start) " ms.")
}