#Requires AutoHotkey v2+

; View OutputDebug messages with https://learn.microsoft.com/en-us/sysinternals/downloads/debugview

logger := LoggerOps()

class LoggerOps {
    write(msg) {
        OutputDebug(A_TickCount " " msg "`n")
    }
    error(msg) {
        this.write("error: " msg)
    }
    warn(msg) {
        this.write("warn: " msg)
    }
    info(msg) {
        this.write("info: " msg)
    }
    debug(msg) {
        ; this.write("debug: " msg)
    }
    trace(msg) {
        ; this.write("trace: " msg)
    }
}
