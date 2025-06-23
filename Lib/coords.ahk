#Requires AutoHotkey v2.0
#Include scaling.ahk

/**
 * x, y coordinates and the width and height of the screen they are based on.
 */
class CoordsBase {
    __New(x, y, width, height) {
        this.x := x
        this.y := y
        this.width := width
        this.height := height
    }

    scaledX() => Round(this.x * dbdWindow.width / this.width)
    scaledY() => Round(this.y * dbdWindow.height / this.height)
    toString() => "(" this.x ", " this.y ")"
    copy(x := this.x, y := this.y, width := this.width, height := this.height) =>
      CoordsBase(x, y, width, height)
}

/**
 * Coordinates for 2K resolution (2560x1440).
 */
class Coords2K extends CoordsBase {
    __New(x, y) => super.__New(x, y, 2560, 1440)
}

/**
 * Coordinates for 1080p resolution (1920x1080).
 */
class Coords1080 extends CoordsBase {
    __New(x, y) => super.__New(x, y, 1920, 1080)
}

coords := CoordsOps()

/**
 * Replacement for ScaledOps that bakes the scaling information into the coordinates.
 */
class CoordsOps {
    click(coords, options := "") {
        scaledX := coords.scaledX()
        scaledY := coords.scaledY()

        logger.trace("click(" coords.x ", " coords.y ") => scaled(" scaledX ", " scaledY ") " options)
        return ops.click(scaledX, scaledY, options)
    }

    getColor(coords) {
        scaledX := coords.scaledX()
        scaledY := coords.scaledY()

        color := ops.getColor(scaledX, scaledY)

        logger.trace("getColor(" coords.x ", " coords.y ") => (" scaledX ", " scaledY ")=" Format("{:06X}", color))

        return color
    }

    mouseMove(coords) {
        scaledX := coords.scaledX()
        scaledY := coords.scaledY()

        logger.trace("mouseMove(" coords.x ", " coords.y ") => (" scaledX ", " scaledY ")")
        return ops.mouseMove(scaledX, scaledY)
    }

    scale(coords) {
        scaledX := coords.scaledX()
        scaledY := coords.scaledY()
        return CoordsBase(scaledX, scaledY, dbdWindow.width, dbdWindow.height)
    }

    ToolTip(msg, coords) {
        scaledX := coords.scaledX()
        scaledY := coords.scaledY()
        ToolTip(msg, scaledX, scaledY)
    }
}
