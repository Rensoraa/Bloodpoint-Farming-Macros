#Requires AutoHotkey v2+

#Include scaling.ahk
#Include colors.ahk
#Include coords.ahk
#Include images.ahk

isDbdFinishedLoading() {
    ; The text of the ESC button moves around at different resolutions.
    ; The gear icon is more stable. Check the rightmost spoke for whiteishness.
    escText := scaled.getColor(438, 1350)
    escTextIsWhite := isWhiteish(escText, 0x70)

    ; Main menu: Middle of the red '<' arrow
    ; Can be a dark red without reshade filters, so we must look at hue rather than red component intensity
    backArrow := scaled.getColor(137, 1345)
    backArrowIsRed := isRedish(backArrow)

    return escTextIsWhite && backArrowIsRed
}

backEscWhiteE := Coords2K(239, 1348)
backRedArrow := Coords2K(137, 1345)
isSettingsOpen() {
    settingsWhiteishMatchDetailsE := coords.getColor(backEscWhiteE)
    settingsRedishBackArrow := coords.getColor(backRedArrow)

    w := isWhiteish(settingsWhiteishMatchDetailsE, 0xB0)
    r := isRedish(settingsRedishBackArrow)
    return w && r
}

isSettingsGraphicsTabSelected() {
    ; 'R' of 'GRAPHICS': (950, 100)
    colorGraphicsR := scaled.getColor(950, 100)
    return isWhiteish(colorGraphicsR)
}

isSettingsGraphicsFpsMenuOpen() {
    ; Check for the base of the 2 of the 120: (1771, 1100)
    colorFps120 := scaled.getColor(1771, 1100)
    return isWhiteish(colorFps120)
}

getBloodwebLevel() {
    ; Decision-tree OCR.
    ; Highly efficient. Zero dependencies. Questionably reliable.
    ; Returns -1 if no level is present.
    ; TODO: Probably thinks a pure white screen is a digit.

    if (dbdWindow.height != 1080 && dbdWindow.height != 1440) {
        ; UI elements move around at other resolutions. It's not going to work.
        return -1
    }

    if dbdWindow.height = 1080
        screenshot := Subscreenshot.of(601, 80, 24, 16)
    else
        screenshot := Subscreenshot.of(795, 106, 33, 23)

    isLit(x, y) {
        ; Check if the pixel is plausibly text in the bloodweb.
        color := screenshot.getColorLiteral(x, y) ; no scaling! coords are specific to 1080 or 1440.

        r := (color >> 16) & 0xFF
        g := (color >> 8) & 0xFF
        b := color & 0xFF
        hsl := RGBtoHSL(r, g, b)

        s := hsl[2]
        l := hsl[3]

        isBright := l >= 0xA0 / 0xFF
        isDesaturated := s < 0.15

        logger.trace("(" x ", " y ")=" color " isBright=" isBright " isDesaturated=" isDesaturated " s=" s)

        return isBright && isDesaturated
    }

    logger.trace("tens:")
    if (dbdWindow.height = 1080) {
        digit10 := isLit(601, 86) ? (isLit(610, 84) ? (isLit(601, 92) ? (isLit(605, 88) ? (isLit(605, 81) ? (8) : (-1)) : (isLit(605, 81) ? (0) : (-1))) : (isLit(608, 93) ? (9) : (-1))) : (isLit(602, 80) ? (isLit(608, 93) ? (5) : (-1)) : (isLit(605, 81) ? (6) : (-1)))) : (isLit(610, 92) ? (isLit(602, 81) ? (isLit(608, 93) ? (3) : (-1)) : (isLit(604, 92) ? (4) : (-1))) : (isLit(601, 84) ? (isLit(601, 95) ? (isLit(607, 90) ? (2) : (-1)) : (isLit(607, 90) ? (1) : (-1))) : (isLit(607, 90) ? (7) : (-1))))
    } else if (dbdWindow.height = 1440) {
        digit10 := isLit(802, 120) ? (isLit(796, 117) ? (isLit(798, 128) ? (isLit(796, 111) ? (9) : (-1)) : (isLit(804, 121) ? (4) : (-1))) : (isLit(809, 126) ? (isLit(806, 108) ? (2) : (-1)) : (isLit(809, 106) ? (isLit(795, 107) ? (7) : (-1)) : (isLit(804, 123) ? (1) : (-1))))) : (isLit(808, 112) ? (isLit(796, 118) ? (isLit(802, 117) ? (isLit(796, 123) ? (8) : (-1)) : (isLit(798, 123) ? (0) : (-1))) : (isLit(796, 111) ? (3) : (-1))) : (isLit(796, 120) ? (isLit(799, 126) ? (6) : (-1)) : (isLit(807, 120) ? (5) : (-1))))
    }

    logger.trace("ones:")
    if (dbdWindow.height = 1080) {
        digit1 := isLit(615, 86) ? (isLit(624, 84) ? (isLit(615, 92) ? (isLit(619, 88) ? (isLit(619, 81) ? (8) : (-1)) : (isLit(619, 81) ? (0) : (-1))) : (isLit(622, 93) ? (9) : (-1))) : (isLit(616, 80) ? (isLit(622, 93) ? (5) : (-1)) : (isLit(619, 81) ? (6) : (-1)))) : (isLit(624, 92) ? (isLit(616, 81) ? (isLit(622, 93) ? (3) : (-1)) : (isLit(618, 92) ? (4) : (-1))) : (isLit(615, 84) ? (isLit(615, 95) ? (isLit(621, 90) ? (2) : (-1)) : (isLit(621, 90) ? (1) : (-1))) : (isLit(621, 90) ? (7) : (-1))))
    } else if (dbdWindow.height = 1440) {
        digit1 := isLit(820, 120) ? (isLit(814, 117) ? (isLit(816, 128) ? (isLit(814, 111) ? (9) : (-1)) : (isLit(822, 121) ? (4) : (-1))) : (isLit(827, 126) ? (isLit(824, 108) ? (2) : (-1)) : (isLit(827, 106) ? (isLit(813, 107) ? (7) : (-1)) : (isLit(822, 123) ? (1) : (-1))))) : (isLit(826, 112) ? (isLit(814, 118) ? (isLit(820, 117) ? (isLit(814, 123) ? (8) : (-1)) : (isLit(816, 123) ? (0) : (-1))) : (isLit(814, 111) ? (3) : (-1))) : (isLit(814, 120) ? (isLit(817, 126) ? (6) : (-1)) : (isLit(825, 120) ? (5) : (-1))))
    }
    screenshot.dispose()

    logger.trace("digit10=" digit10 " digit1=" digit1)

    ; Bloodweb level is left-aligned, so the tens digit actually houses levels 0-9 and the ones digit is empty.
    ; If tens digit is missing, then it's not a valid bloodweb level.
    if (digit10 = -1)
        return -1
    if (digit1 = -1)
        return digit10
    level := digit10 * 10 + digit1
    logger.debug("level=" level)
    return level
}

isAbandonEscapeOptionVisible() {
    ; Samples the [ESC] ABANDON button background in the top right
    ; in a spot that's common across keyboard (ESC), PS5 (OPTIONS)
    blackBg1 := Coords2K(2202, 104)
    if coords.getColor(blackBg1) != 0
        return false

    blackBg2 := Coords2K(2202, 80)
    if coords.getColor(blackBg2) != 0
        return false

    ; White text, or Xbox hamburger button
    escEWhite := Coords2K(2201, 92)
    if !isWhiteish(coords.getColor(escEWhite), 0xF0)
        return false

    ; TODO: this doesn't pass for all tests.
    ; escCWhite := Coords2K(2208, 92)
    ; if !isWhiteish(coords.getColor(escCWhite), 0xF0)
    ;     return false

    return true
}

isAbandonConfirmOpen() {
    ; After we click Abandon, we get a confirmation dialog
    ; It has a title of ABANDON in pure white
    global confirmWhiteA := scaled.getColor(1171, 380)
    global confirmWhiteN := scaled.getColor(1375, 372)
    return confirmWhiteA = 0xFFFFFF and confirmWhiteN = 0xFFFFFF
}

isHookSpaceOptionAvailable() {
    ; Head of the "carried survivor" icon.
    ; Chosen because it is not white in the same spot as the "Blight Rush" icon.
    colorHead := scaled.getColor(227, 1254)

    ; White part of the 'A' of the "[SPACE] HANG" prompt.
    colorSpaceA := scaled.getColor(1235, 1265)

    ; Black background of the "[SPACE] HANG" prompt to disqualify an all white screen.
    colorSpaceBg := scaled.getColor(1235, 1269)

    return colorHead = 0xFFFFFF && colorSpaceA = 0xFFFFFF && colorSpaceBg = 0x000000
}

tallyLeftArrowWhite := Coords2K(367, 1196)
tallyLeftArrowDark := Coords2K(353, 1193)

tallyRightArrowWhite := Coords2K(859, 1197)
tallyRightArrowDark := Coords2K(872, 1194)

tallyContinueButtonRed := Coords2K(2421, 1348)

isTallyScreen() {
    isLeftArrowWhiteish() => isWhiteish(coords.getColor(tallyLeftArrowWhite))
    isLeftArrowBlackish() => isBlackish(coords.getColor(tallyLeftArrowDark), , tolerance := 10)

    isRightArrowWhite() => isWhiteish(coords.getColor(tallyRightArrowWhite))
    isRightArrowBlackish() => isBlackish(coords.getColor(tallyRightArrowDark), , tolerance := 10)

    isContinueButtonRedish() => isRedish(coords.getColor(tallyContinueButtonRed))

    return isLeftArrowWhiteish() && isLeftArrowBlackish() && isRightArrowWhite() && isRightArrowBlackish() && isContinueButtonRedish()
}

tallyScoreMatchText := Coords2K(158, 630)
isTallyBloodpointsScreen() => isWhiteish(coords.getColor(tallyScoreMatchText), threshold := 0xF8)

cancelButtonRedMarker := Coords2K(2433, 1283)
isReadiedUp() => isRedish(coords.getColor(cancelButtonRedMarker))

readyButtonRedBar := Coords2K(2430, 1257)
readyButtonWhiteR := Coords2K(2278, 1260)
isReadyButtonVisible() {
    return isRedish(coords.getColor(readyButtonRedBar)) and isWhiteish(coords.getColor(readyButtonWhiteR), threshold := 0x90)
}

isQVisible() {
    whiteQ := Coords2K(417, 1131)
    blackQLeft := Coords2K(413, 1131)
    blackQRight := Coords2K(419, 1131)

    return coords.getColor(whiteQ) = 0xFFFFFF and coords.getColor(blackQLeft) = 0 and coords.getColor(blackQLeft) = 0
}
