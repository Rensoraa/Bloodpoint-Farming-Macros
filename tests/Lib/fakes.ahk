#Requires AutoHotkey v2.0

#Include ..\..\Lib\scaling.ahk
#Include ..\..\Lib\Gdip_All.ahk
#Include ..\Yunit\Yunit.ahk

class DbdTestWindow extends DbdWindowOps {
    __New(pBitmap) {
        if !pBitmap
            throw Error("DbdTestWindow requires a pBitmap")
        this.pBitmap := pBitmap
    }
    checkScale() {
        this._width := Gdip_GetImageWidth(this.pBitmap)
        this._height := Gdip_GetImageHeight(this.pBitmap)
    }
}

class TestOps extends WindowOps {
    __New(pBitmap) {
        if !pBitmap
            throw Error("TestOps requires a pBitmap")
        this.pBitmap := pBitmap
    }

    getColor(x, y) {
        return Gdip_GetPixel(this.pBitmap, x, y) & 0xFFFFFF
    }
}
class TestLogger extends LoggerOps {
    write(level, msg) {
        path := "?"
        line := "?"
        method := "?"
        filename := "?"
        try {
            throw Error("Capture stack")
        } catch as e {
            lines := StrSplit(e.Stack, "`n")
            if lines.Length >= 2 {
                match := ""
                if RegExMatch(lines[3], "(.*?) \((\d+)\) : \[([^]]*)\] .*", &match) {
                    path := match[1]
                    line := match[2]
                    method := match[3]
                    filename := RegExReplace(path, "^.*?\\Bloodpoint-Farming-Macros\\", "")
                }
            }
        }
        vsCodeRef := ".\" filename ":" line
        FileAppend(method ": " msg " [" vsCodeRef "]`n", "*")
    }
    error(msg) => this.write("error", msg)
    warn(msg) => this.write("warn", msg)
    info(msg) => this.write("info", msg)
    debug(msg) => this.write("debug", msg)
    trace(msg) => this.write("trace", msg)
}

/**
 * Yunit doesn't support exit codes, so we need to implement our own to fail in CI.
 */
class YunitExitOnTestFailure {
    __New(instance) {
        this.pass := 0
        this.fail := 0
    }

    Update(Category, TestName, Result) {
        if Result is Error {
            this.fail += 1
        } else {
            this.pass += 1
        }
    }

    __Delete() {
        if (this.fail > 0) {
            logger.warn("FAIL: " this.fail " tests failed!")

            ; We don't want to exit if we are running in the IDE--only in CI.
            ; Env var set via github actions
            if (EnvGet("YUNIT_EXIT_ON_TEST_FAILURE") == "1") {
                logger.warn("exiting with code 1")
                ExitApp(1)
            }
        } else {
            logger.warn("PASS: " this.pass " tests passed.")
        }
    }
}

setupFakeWindow(screenshotPath) {
    global dbdWindow, ops, scaled, Gdip_BitmapFromScreenDelegate
    pBitmap := Gdip_CreateBitmapFromFile(screenshotPath)
    Gdip_BitmapFromScreenDelegate := (x, y, w, h) => Gdip_CloneBitmapArea(pBitmap, x, y, w, h)
    dbdWindow := DbdTestWindow(pBitmap)
    ops := TestOps(pBitmap)
    return pBitmap
}

assertFor(screenshot, predicate) {
    screenshotPath := A_ScriptDir "\screenshots\" screenshot
    pBitmap := setupFakeWindow(screenshotPath)
    Yunit.Assert(predicate.Call())
    Gdip_DisposeImage(pBitmap)
}
