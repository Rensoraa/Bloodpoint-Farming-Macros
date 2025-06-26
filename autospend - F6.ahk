#Requires AutoHotkey v2+
/*
Bloodweb autospender using the speed tech from:
https://www.reddit.com/r/deadbydaylight/s/njguTZBODp
*/
#HotIf WinActive(dbdWinTitle)
#Include Lib\common.ahk
#Include Lib\bloodweb.ahk
#MaxThreadsPerHotkey 2

setTrayIcon("icons/autopurchase.ico")

/**
 * Enables additional info and screnshot capturing.
 */
debug := false

/**
 * Autopurchase when there are no more nodes of interest that require claiming.
 * Can be disabled for debugging to test individual node claiming.
 */
useAutopurchase := true

/**
 * Uses the bulk spend between level 50 and 10.
 */
useBulkSpend := true
bulkSpendToLevel := 10

bw := Bloodweb([], [], [])
toolTipLocation := Coords2K(518, 150) ; Under character name and level

; Start spending
~F6:: {
    if enabled
        requestStop()
    else
        setEnabled(true)
}

~^+F6:: {
    ; Debug stub to check level-detection without actually spending
    setEnabled(true)
    showUnmarkedNodes()
}

prevLevel := -1
enabled := false
stopRequested := false

requestStop() {
    global stopRequested
    stopRequested := true
    coords.ToolTip("Stopping...", toolTipLocation)
}

setEnabled(newState) {
    global enabled, stopRequested
    if enabled = newState
        return

    enabled := newState
    stopRequested := false

    logger.info((enabled ? "Started" : "Stopped") " spending")

    coords.ToolTip(enabled ? "Spending. F6 or Alt+Tab to stop." : "", toolTipLocation)
    if enabled {
        startSpending()
    }
}

shouldKeepRunning() {
    ; Stop if the user tabs out or have requested to stop.
    if stopRequested or !WinActive(dbdWinTitle)
        setEnabled(false)
    return enabled
}

setPrevLevel(l) {
    global prevLevel
    prevLevel := l
}

startSpending() {
    setBloodwebSize()

    level := getBloodwebLevel()
    if (level = -1) {
        ; Bloodweb is not visible. Open it.
        coords.click(bloodwebTab)

        ; Then cycle it to make the contents load instantly.
        Sleep(100)
        cycleBloodweb()
    }

    ; Initialize to the current level to avoid cycling unnecessarily.
    setPrevLevel(getBloodwebLevel())

    coords.mouseMove(topLeft)
    autospend()
}

autospend() {
    while shouldKeepRunning() {
        level := getBloodwebLevel()
        logger.info("Level " level)

        if (level > 0 && prevLevel != level or Bloodweb.isP100) {
            ; Cancel the bloodweb loading animation
            cycleBloodweb()
            setPrevLevel(level)
        }

        ; Wait for the bloodweb to load.
        while !waitUntilF(() => Bloodweb.isLoaded() or !shouldKeepRunning(), 5000) {
            ; Bloodweb didn't load. Why?
            if !shouldKeepRunning()
                return

            logger.warn("Bloodweb didn't load!")
            if Bloodweb.isBloodwebError() {
                logger.info("Handling bloodweb error.")
                coords.click(Bloodweb.bloodwebErrorOkButtonRed)
            } else {
                coords.click(bloodwebTab)
            }
        }

        ; If we resume at low levels, bulk spend.
        if useBulkSpend and level > 0 and level < bulkSpendToLevel {
            bulkSpend()
            continue
        }

        ; Buy specific items
        if !useAutopurchase or !isGuranteedLevel(level) {
            if shouldKeepRunning()
                buyMarkedItems()
        }

        ; Bulk spend at level 50 after picking out the things we want. Skip the prestige interstitial.
        if useBulkSpend and level = 50 and !Bloodweb.isP100() {
            bulkSpend()
            continue
        }

        if useAutopurchase {
            ; Autopurchase untagged items.
            autoPurchase()
        }
    }
}

autoPurchase() {
    ; Left of the button to avoid tooltip.
    apbLeftRed := dbdWindow.height = 1440 ? Coords2K(884, 756) : Coords1080(663, 563)
    isP100 := Bloodweb.isP100()
    logger.info("isP100=" isP100)
    
    hasRedDisappeared := false
    isAutoPurchaseComplete() {
        if !shouldKeepRunning()
            return true

        if isP100 {
            ; We can't rely on the level changing. It stays 50 forever.
            ; For lack of anything better, we're going to watch for the red button
            ; to disappear and reappear. This is suboptimal, but I'm out of time to
            ; think of something better.
            color := coords.getColor(apbLeftRed)
            hsv := colorToHSV(color)
            h := hsv[1]
            s := hsv[2]
            redishNow := (h > 350 or h < 15) and s > 0.5 ; isRedish() can't handle red this dark.

            if !hasRedDisappeared and !redishNow {
                logger.debug("No longer redish: " Format("{:06X}", color))
                hasRedDisappeared := true
            }

            redReturned := hasRedDisappeared and redishNow
            return redReturned
        } else {
            return hasLevelChanged()
        }
    }

    clickAutopurchase()
    ; Retry until something happens.
    doWithRetriesUntilF(
        action := clickAutopurchase,
        predicate := isAutoPurchaseComplete,
        maxDurationMs := 10000,
        timeBetweenRetries := 500
    )
}

bulkSpend() {
    logger.info("Bulk spending to level " bulkSpendToLevel)

    ; Open bulk dialog
    waitUntilF(() => Bloodweb.isBulkSpendVisible())
    coords.click(Bloodweb.bulkSpendButton)

    Sleep(100) ; it loads fast. probably overkill.

    ; Set levels
    levels := bulkSpendToLevel - Mod(prevLevel, 50) - 1
    loop levels {
        coords.click(Bloodweb.bulkSpendLevelPlusButton)
        Sleep(20)
    }

    ; Confirm purchase (this button doesn't register clicks reliably, so we must spam)
    doWithRetriesUntilF(
        action := () => slowClick(Bloodweb.bulkSpendConfirmButton, 100),
        predicate := () => !Bloodweb.isBulkSpendConfirmButtonVisible(),
        maxDurationMs := 2000,
        timeBetweenRetries := 200
    )
    ops.mouseMove(0, 0) ; don't depend on red hover glow for next step. user may move mouse.

    ; Done
    waitUntilF(() => Bloodweb.isBulkSpendOkVisible(), 5000)
    doWithRetriesUntilF(
        action := () => slowClick(Bloodweb.bulkSpendOkButtonRed, 100),
        predicate := () => !Bloodweb.isBulkSpendOkVisible(),
        maxDurationMs := 1000,
        timeBetweenRetries := 200
    )
}

clickAutopurchase() {
    if useAutopurchase {
        logger.info("Clicking autopurchase.")
        slowClick(Bloodweb.autopurchaseButton)
    } else {
        logger.info("Suppressed: Clicking autopurchase.")
    }
}

hasLevelChanged() => getBloodwebLevel() != prevLevel

isGuranteedLevel(level) => level >= 1 and level <= 11 and level != 10

buyMarkedItems() {
    logger.debug("Checking for marked items")
    ; Hide autopurchase tooltip
    scaled.mouseMove(0, 0)

    ; Wait for items to load
    waitUntilF(() => Bloodweb.isLoaded(), 3000)
    Sleep(40) ; Sometimes the icons don't load for a couple frames. This needs to be here!

    sw := Stopwatch("Buy marked items")
    /**
     * Overestimate of the number of nodes consumed.
     */
    approxNodesConsumed := 0

    ; PixelGetColor x30 nodes takes ~110 ms.
    ; Direct memory access x30 nodes takes ~40ms.
    ; Screenshot yields better performance when items of interest are sparse.
    ; We'll use the same screenshot across the whole bloodweb level.
    ; Since we work from outside to inside, some inside nodes may get consumed early,
    ; but this is fine since we recheck for the marker (which will be missing) before clicking.
    screenshot := bw.subscreenshot()

    ; Determine priority of each tagged node.
    queue := Map()
    for node in bw.all {
        if node.isTeal(screenshot) and node.isBlue(screenshot) {
            color := screenshot.getColor(node.topLeft)
            pri := Bloodweb.markerPriority(color)
            if !queue.Has(pri)
                queue[pri] := []

            arr := queue[pri].Push(node)
        }
    }

    for pri, nodes in queue {
        logger.info("Priority " pri ": " nodes.Length " nodes...")
        approxNodesConsumed += buyItemsAtPoints(nodes, screenshot)
    }

    ; Only do the inner ring if the entity can actually reach it.
    ; We always get 6 guaranteed nodes before the entity starts consuming.
    ; Inner ring has 6 nodes and entity has to consume 2 before hitting inner ring.
    ; TODO: figure out how to reimplement this optimization
    ; if approxNodesConsumed > 2 or !useAutopurchase {
    ;     buyItemsAtPoints(bw.innerRing, screenshot)
    ; }
    saveScreenshot(screenshot)
    screenshot.dispose()
    sw.report()
}

saveScreenshot(screenshot) {
    if debug {
        dir := A_Temp "\Autospend"
        path := dir "\level-" prevLevel ".png"
        if !DirExist(dir)
            DirCreate(dir)
        Gdip_SaveBitmapToFile(screenshot.img.pBitmap, path)
        logger.info("Screenshot saved to " path)
    }
}

/**
 * @returns number of nodes consumed
 */
buyItemsAtPoints(points, screenshot) {
    approxNodesConsumed := 0

    for point in points {
        if !shouldKeepRunning()
            return approxNodesConsumed

        local node := point

        if node.isTeal(screenshot) and node.isBlue(screenshot) {
            ; Node was of interest at the time the screnshot was taken
            waitUntilF(() => !Bloodweb.isLoading(), 3000)
            doWithRetriesUntilF(
                action := () => clickNode(node),
                predicate := () => !node.isTeal(coords) or !enabled,
                maxDurationMs := 5000,
                timeBetweenRetries := 2000
            )
            approxNodesConsumed += node.depth
        }
    }
    return approxNodesConsumed
}

/**
 * Debugging tool
 */
showUnmarkedNodes() {
    setBloodwebSize()
    screenshot := bw.subscreenshot()

    for node in bw.all {
        if !shouldKeepRunning()
            return

        t := node.isTeal(screenshot)
        b := node.isBlue(screenshot)
        isMarked := t and b
        if !isMarked {
            msg := isMarked ? "Marked" : "NOT Marked (teal=" t " blue=" b ")"
            ToolTip(msg, node.center.x, node.center.y)
            Sleep(isMarked ? 500 : 1000)
        }
    }

    setEnabled(false)
}

setBloodwebSize() {
    global bw
    bw := Bloodweb.fromHeight(dbdWindow.height)
    if !bw.all.Length {
        MsgBox("Autospend only supports 1080p and 1440p. Run windowed if you need to.")
        setEnabled(false)
    }
}

cycleBloodweb() {
    ; Closing and opening the bloodweb skips the "level" interstitial
    logger.info("Cycling bloodweb")
    coords.click(bloodwebTab) ; bloodweb tab
    Sleep(100)
    coords.click(bloodwebTab) ; bloodweb tab
}

slowClick(p, holdTime := 50) {
    if !shouldKeepRunning()
        return

    logger.debug("Clicking " p.toString())
    coords.click(p, "down")
    Sleep(holdTime)
    coords.click(p, "up")
}

clickNode(node) {
    slowClick(node.center, 100)
    scaled.mouseMove(0, 0)
}

expectedNextLevel() {
    if (prevLevel = 50)
        return 1
    return prevLevel + 1
}

bloodwebTab := Coords2K(201, 459)
characterTab := Coords2K(201, 143)
topLeft := Coords2K(0, 0)