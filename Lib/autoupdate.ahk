#Requires AutoHotkey v2.0

#Include logging.ahk
#Include files.ahk

class AutoUpdate {
    stateDir := A_AppData "\Bloodpoint-Farming-Macros"
    installDir := ""
    url := "https://bloodpointfarming.github.io/Bloodpoint-Farming-Macros/Bloodpoint-Farming-Macros.zip"
    etagFile => this.stateDir "\etag.txt"
    lastUpdateCheckFile => this.stateDir "\last_update_check.txt"

    __New() {
        DirCreate(this.stateDir)
        installDir := ""
        SplitPath(A_LineFile, , &installDir)
        this.installDir := installDir "\.."
    }

    UpdateIfNewVersion() {
        try {
            if this.isGitRepo() {
                logger.info("Running from git repo. Skipping auto-update. Use git pull instead.")
                return
            }

            if !this.isUpdateTime() {
                logger.info("Already checked for update recently. Skipping update check.")
                return
            }

            ; Mark that we checked for an update so we don't retry for a while
            FileOverwite(A_Now, this.lastUpdateCheckFile)

            newEtag := this.getLatestEtag()
            currentEtag := this.getCurrentEtag()
            logger.info("currentEtag=" currentEtag " newEtag=" newEtag)
            if newEtag = currentEtag {
                logger.info("No update needed.")
                return
            }

            if !this.doesUserAgreeToUpdate() {
                logger.info("Update available, but user declined update.")
                return
            }

            this.installLatestUpdate()

            ; Record the new ETag
            FileOverwite(newEtag, this.etagFile)

            logger.debug("Update complete.")

            this.reportSuccess()
        } catch Error as e {
            msg := "Error during update on " e.File ":" e.Line " " e.Message "`n" e.Stack
            logger.error(msg)
            this.MsgBox("Update failed on line " e.Line ". Giving up for now. Won't try again for at least 12 hours.", "Update Failed", 0x10)
        }
    }

    isGitRepo() => FileExist(this.installDir "\.git")

    isUpdateTime() {
        if !FileExist(this.lastUpdateCheckFile)
            return true

        lastUpdateCheck := FileRead(this.lastUpdateCheckFile)
        elapsedHours := DateDiff(A_Now, lastUpdateCheck, "Hours")
        return elapsedHours > 12
    }

    getLatestEtag() {
        ; Check for updates via latest ETag.
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("HEAD", this.url, false)
        whr.Send()
        etag := whr.GetResponseHeader("ETag")
        etag := RegExReplace(etag, "[^a-zA-Z0-9]", "")
        logger.debug("latest ETag from server: " etag)
        return etag
    }

    getCurrentEtag() {
        oldEtag := ""
        ; Get the ETag for our current version (if recorded)
        if FileExist(this.etagFile) {
            oldEtag := FileRead(this.etagFile)
        }
        return oldEtag
    }

    doesUserAgreeToUpdate() {
        response := this.MsgBox("Macro updates are available. Update now?", "Macro Updates Available", 0x4 | 0x20)
        return response = "Yes"
    }

    installLatestUpdate() {
        zipFile := A_Temp "\Bloodpoint-Farming-Macros.zip"

        ; Download the zip
        this.downloadZip(zipFile)
        logger.debug("Downloaded new ZIP to " zipFile)

        ; Clear old directory contents. Ignore failures due to locked files.
        if DirExist(this.installDir) {
            loop files this.installDir "\*", "FR" {
                try {
                    if A_LoopFileAttrib ~= "D" {
                        DirDelete(A_LoopFilePath, Recurse := true)
                    } else {
                        FileDelete(A_LoopFilePath)
                    }
                }
            }
        }

        ; Unzip new macros into place
        DirCopy(zipFile, this.installDir, Overwrite := true)

        ; Remove the temp zip file
        FileDelete zipFile
    }

    downloadZip(zipFile) {
        Download(this.url, zipFile)
    }

    reportSuccess() {
        ; Feedback for the user
        if FileExist(A_ScriptFullPath) {
            ; Update was successful and script is still in the same location.
            this.MsgBox("Update complete. Reloading to pick up the changes.", "Update Complete")
            this.Reload()
        } else {
            ; Script probably moved to a new location.
            this.MsgBox("Update complete. Please restart the script.", "Update Complete")
            this.Exit()
        }
    }

    MsgBox(params*) => MsgBox(params*)
    Reload() => Reload()
    Exit() => Exit()
}
