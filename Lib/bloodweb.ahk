#Requires AutoHotkey v2+

#Include scaling.ahk
#Include colors.ahk
#Include coords.ahk
#Include images.ahk

class Bloodweb {
    all := []

    __New(outerRing, middleRing, innerRing) {
        this.outerRing := outerRing
        this.middleRing := middleRing
        this.innerRing := innerRing
        this.all.Push(outerRing*)
        this.all.Push(middleRing*)
        this.all.Push(innerRing*)

        ; Find the bounds for screenshotting later.
        this.minX := 9999
        this.minY := 9999
        this.maxX := 0
        this.maxY := 0
        for node in this.all {
            this.minX := Min(this.minX, node.bottomLeft.x, node.bottomRight.x)
            this.minY := Min(this.minY, node.bottomLeft.y, node.center.y)
            this.maxX := Max(this.maxX, node.bottomLeft.x, node.bottomRight.x)
            this.maxY := Max(this.maxY, node.bottomLeft.y, node.center.y)
        }
        this.width := this.maxX - this.minX + 1
        this.height := this.maxY - this.minY + 1
    }

    static fromHeight(height) {
        if height = 1440 {
            return Bloodweb(
                outerRing := [
                    ; Outer ring ordered from right to left to avoid issues with the tooltip
                    Bloodweb.Node(396, 792), ; 9
                    Bloodweb.Node(1356, 792), ; 3
                    Bloodweb.Node(1289, 1024), ; 4
                    Bloodweb.Node(1116, 1199), ; 5
                    Bloodweb.Node(1291, 560), ; 2
                    Bloodweb.Node(1116, 386), ; 1
                    Bloodweb.Node(875, 1263), ; 6
                    Bloodweb.Node(876, 322), ; 12
                    Bloodweb.Node(635, 1199), ; 7
                    Bloodweb.Node(636, 385), ; 11
                    Bloodweb.Node(460, 560), ; 10
                    Bloodweb.Node(461, 1024), ; 8
                ],
                middleRing := [
                    Bloodweb.Node(554, 711), ; 9:30
                    Bloodweb.Node(1198, 874), ; 3:30
                    Bloodweb.Node(1114, 1022), ; 4:30
                    Bloodweb.Node(958, 1104), ; 5:30
                    Bloodweb.Node(1198, 711), ; 2:30
                    Bloodweb.Node(1114, 563), ; 1:30
                    Bloodweb.Node(793, 1104), ; 6:30
                    Bloodweb.Node(958, 480), ; 12:30
                    Bloodweb.Node(639, 1021), ; 7:30
                    Bloodweb.Node(793, 480), ; 11:30
                    Bloodweb.Node(638, 562), ; 10:30
                    Bloodweb.Node(554, 874), ; 8:30
                ],
                innerRing := [
                    Bloodweb.Node(1016, 875), ; 4
                    Bloodweb.Node(1016, 710), ; 2
                    Bloodweb.Node(875, 956), ; 6
                    Bloodweb.Node(875, 630), ; 12
                    Bloodweb.Node(736, 875), ; 8
                    Bloodweb.Node(736, 710), ; 10
                ]
            )
        }
        else if height = 1080 {
            return Bloodweb(
                outerRing := [
                    ; Outer ring ordered from right to left to avoid issues with the tooltip
                    Bloodweb.Node(657, 942),
                    Bloodweb.Node(837, 894),
                    Bloodweb.Node(968, 763),
                    Bloodweb.Node(477, 895),
                    Bloodweb.Node(968, 415),
                    Bloodweb.Node(837, 284),
                    Bloodweb.Node(657, 236),
                    Bloodweb.Node(346, 763),
                    Bloodweb.Node(1017, 589),
                    Bloodweb.Node(477, 284),
                    Bloodweb.Node(346, 415),
                    Bloodweb.Node(297, 589),
                ],
                middleRing := [
                    Bloodweb.Node(719, 823),
                    Bloodweb.Node(595, 823),
                    Bloodweb.Node(835, 761),
                    Bloodweb.Node(719, 355),
                    Bloodweb.Node(898, 650),
                    Bloodweb.Node(595, 355),
                    Bloodweb.Node(479, 761),
                    Bloodweb.Node(898, 528),
                    Bloodweb.Node(835, 417),
                    Bloodweb.Node(416, 650),
                    Bloodweb.Node(479, 417),
                    Bloodweb.Node(416, 528),
                ],
                innerRing := [
                    Bloodweb.Node(762, 651),
                    Bloodweb.Node(657, 712),
                    Bloodweb.Node(762, 527),
                    Bloodweb.Node(552, 651),
                    Bloodweb.Node(657, 467),
                    Bloodweb.Node(552, 527),
                ]
            )
        }
        else
            return Bloodweb([], [], [])
    }

    subscreenshot() => Subscreenshot.of(this.minX, this.minY, this.width, this.height)

    static isTealMarker(color) => Bloodweb.matchesHue(color, 160, 171)

    static isBlueMarker(color) => Bloodweb.matchesHue(color, 239, 255)

    static autopurchaseButton := Coords2K(910, 755)
    static autopurchaseButtonLoading() => dbdWindow.height = 1080 ? Coords1080(700, 596) : Coords2K(933, 800)

    static isLoaded() {
        buttonVisible := isRedish(coords.getColor(Bloodweb.autopurchaseButton))
        return buttonVisible && !Bloodweb.isLoading()
    }
    static isLoading() => isRedish(coords.getColor(Bloodweb.autopurchaseButtonLoading()))

    static matchesHue(color, hueMin, hueMax) {
        ; Inlined for perf since it's hot while identify marker tags.
        ; Note the early returns in different places for HSV.
        static inv255 := 1.0 / 255

        ; ; Quick test for red <= 0x1F, green > 0x80
        ; if (color & 0xe08000 != 0x008000)
        ;     return false

        r := (color >> 16) & 0xFF
        g := (color >> 8) & 0xFF
        b := color & 0xFF

        maxVal := Max(r, g, b)

        ; Calculate Value
        if (maxVal <= 0.25 * 255)
            return false

        ; Calculate Saturation
        minVal := Min(r, g, b)
        delta := maxVal - minVal
        if (delta = 0)
            return false ; hue == 0

        ; Saturation as [0..1]
        s := (delta / maxVal)
        if (s <= 0.5)
            return false

        ; Hue calculation (in degrees)
        if (maxVal = r)
            h := 60 * Mod(((g - b) / delta), 6)
        else if (maxVal = g)
            h := 60 * (((b - r) / delta) + 2)
        else
            h := 60 * (((r - g) / delta) + 4)

        if (h < 0)
            h += 360

        ; Target hue is 165, but beige circle bg makes it as warm as 161
        return h > hueMin and h < hueMax
    }

    static bloodwebErrorOkButtonRed := Coords2K(1915, 880)
    static bloodwebErrorOkButtonBlack := Coords2K(1920, 880)
    static bloodwebErrorOkButtonWhite := Coords2K(1886, 880)
    static bloodwebErrorBarOutsideBloodwebRed := Coords2K(2166, 524)
    static isBloodwebError() {
        return isRedish(coords.getColor(Bloodweb.bloodwebErrorBarOutsideBloodwebRed)) and
        isRedish(coords.getColor(Bloodweb.bloodwebErrorOkButtonRed)) and
        isBlackish(coords.getColor(Bloodweb.bloodwebErrorOkButtonBlack), , tolerance := 16) and
        isWhiteish(coords.getColor(Bloodweb.bloodwebErrorOkButtonWhite), , tolerance := 16)
    }

    class Node {
        __New(x, y) {
            this.bottomLeft := CoordsBase(x, y, dbdWindow.width, dbdWindow.height)

            offset := scaled.scaleX(30)
            this.center := this.bottomLeft.copy(this.bottomLeft.x + offset, this.bottomLeft.y - offset)
        }

        bottomRight => this.bottomLeft.copy(x := this.bottomLeft.x + Ceil(scaled.scaleX(65)))

        isTeal(api) => Bloodweb.isTealMarker(api.getColor(this.bottomLeft))
        isBlue(api) => Bloodweb.isBlueMarker(api.getColor(this.bottomRight))
    }

    static bulkSpendButton := Coords2K(1419, 286)
    static isBulkSpendVisible() {
        c := coords.getColor(Bloodweb.bulkSpendButton)
        s := colorToHSL(c)[2]
        return s < 0.1
    }
    static bulkSpendLevelPlusButton := Coords2K(1520, 654)
    static bulkSpendConfirmButton := Coords2K(2010, 1111)
    static isBulkSpendConfirmButtonVisible() {
        ; This is very indirect, but we're looking for the pure black region above the button.
        button := Bloodweb.bulkSpendConfirmButton
        aboveBlack := coords.getColor(button.copy(, button.y - scaled.scaleY(60)))
        return (aboveBlack & 0xFFFFFF) = 0
    }
    static bulkSpendOkButtonRed := Coords2K(2021, 1120)
    static isBulkSpendOkVisible() => isRedish(coords.getColor(Bloodweb.bulkSpendOkButtonRed))
}
