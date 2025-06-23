#Requires AutoHotkey v2+

#Include ..\Lib\common.ahk
#Include ..\Lib\Gdip_All.ahk
ListLines(0) ; perf
Persistent(0)
pToken := Gdip_Startup()

imageDir := A_MyDocuments "\..\dbd\screenshots\bloodweb\nodes\1080"
imageHeight := 1080
MarkerThreshold := imageHeight * 20 / 1080 ; Pixel distance threshold to group points into the same marker
minBlobWidth := imageHeight * 5 / 1080

; Ignore regions where markers cannot appear for perf
bloodwebXStartPct := 260 / 1920
bloodwebXEndPct := 1122 / 1920
bloodwebYStartPct := 150 / 1080
bloodwebYEndPct := 990 / 1080

findMarkers()

findMarkers() {
    MarkerPresence := Map(), MarkerBottoms := Map()

    imageIndex := 0
    loop files, imageDir "\*.png" {
        logger.info("Reading " A_LoopFileFullPath)
        pBitmap := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
        img := PBitmapImage(pBitmap)

        msg := "Finding markers " A_LoopFileFullPath
        imageTimer := stopwatch(msg)
        foundMarkers := [] ; List of [x, y] for this image
        xStart := Integer(bloodwebXStartPct * img.width)
        yStart := Integer(bloodwebYStartPct * img.height)
        width := Integer(bloodwebXEndPct * img.width - xStart)
        height := Integer(bloodwebYEndPct * img.height - yStart)

        visited := Map()

        t := stopwatch("Finding marker blobs")
        loop height {
            y := yStart + A_Index - 1
            loop width {
                x := xStart + A_Index - 1
                rgb := img.getColor(x, y)
                if isTealMarker(rgb) && !visited.Has(x "," y) {
                    blob := floodFillMarker(img, x, y, visited)
                    if isBlobMarker(blob) {
                        bottomLeft := getBottomLeft(blob)
                        foundMarkers.Push(bottomLeft)
                        logger.info("Marker: (" x ", " y ") color=" Format("{:06X}", rgb & 0xFFFFFF) " pixels=" blob.Length)
                    }
                }
            }
        }
        t.report()
        logger.info("Found markers: " foundMarkers.Length)

        ; Match found markers to global positions
        for marker in foundMarkers {
            matched := false
            for location in MarkerPresence {
                if distance(location, marker) <= MarkerThreshold {
                    MarkerPresence[location].Push(marker)
                    if !MarkerBottoms.Has(location)
                        MarkerBottoms[location] := Map()
                    MarkerBottoms[location][imageIndex] := MarkerBottoms[location].Has(imageIndex)
                        ? MarkerBottoms[location][imageIndex].Push(marker)
                        : [marker]
                    matched := true
                    break
                }
            }
            if !matched {
                MarkerPresence[marker] := [marker]
                MarkerBottoms[marker] := Map()
                MarkerBottoms[marker][imageIndex] := [marker]
            }
        }

        imageIndex++
        imageTimer.report()
        Gdip_DisposeImage(pBitmap)
    }

    logger.info("Found " MarkerPresence.Count " total markers.")

    ; Calculate center of all marker positions across all locations
    allMarkerPixels := []
    for _, imagesMap2 in MarkerBottoms {
        for _, pixelList2 in imagesMap2
            allMarkerPixels.Push(pixelList2*)
    }
    sumX := 0, sumY := 0
    for _, pt in allMarkerPixels {
        sumX += pt.x
        sumY += pt.y
    }
    center := { x: sumX / allMarkerPixels.Length, y: sumY / allMarkerPixels.Length }

    sortedMarkers := Map()

    for location, imagesMap in MarkerBottoms {
        allPixels := []
        for _, pixelList in imagesMap
            allPixels.Push(pixelList*)

        ; Count each coordinate
        coordCount := Map()
        for pt in allPixels {
            key := pt.x "," pt.y
            coordCount[key] := coordCount.Has(key) ? coordCount[key] + 1 : 1
        }

        required := imagesMap.Count
        commonPixels := []
        for key, count in coordCount {
            if count = required {
                arr := StrSplit(key, ",")
                commonPixels.Push({ x: arr[1], y: arr[2] })
            }
        }

        if commonPixels.Length {
            bottomLeft := getBottomLeft(commonPixels)
            dist := distance(bottomLeft, center)
            sortedMarkers[dist] := bottomLeft
            logger.info("Common marker at: (" bottomLeft.x ", " bottomLeft.y ") dist=" dist)
        } else {
            logger.warn("No common pixel found for marker at ~(" location.x ", " location.y ")")
        }
    }

    logger.info("=== Sorted Markers ===")
    for dist, bottomLeft in sortedMarkers {
        OutputDebug("Coords1080(" bottomLeft.x ", " bottomLeft.y ")") ; dist=" dist)
    }
}

floodFillMarker(img, startX, startY, visited) {
    global MarkerThreshold
    q := [[startX, startY]]
    blob := []
    while q.Length {
        pt := q.Pop()
        x := pt[1], y := pt[2]
        key := x "," y
        if visited.Has(key)
            continue
        visited[key] := true

        rgb := img.getColor(x, y)
        if !isTealMarker(rgb)
            continue

        blob.Push({ x: x, y: y })

        ; Check 8 neighbors
        for dx in [-1, 0, 1] {
            for dy in [-1, 0, 1] {
                if (dx != 0 || dy != 0) {
                    nx := x + dx
                    ny := y + dy
                    if (0 <= nx && nx < img.width && 0 <= ny && ny < img.height)
                        q.Push([nx, ny])
                }
            }
        }
    }
    return blob
}

getBottomLeft(points) {
    ; Return point with max y, and if tie, min x
    bottomLeft := points[1]
    for pt in points {
        if (pt.y > bottomLeft.y || (pt.y == bottomLeft.y && pt.x < bottomLeft.x)) {
            bottomLeft := pt
        }
    }
    return bottomLeft
}

distance(pt1, pt2) {
    dx := pt1.x - pt2.x
    dy := pt1.y - pt2.y
    return Sqrt(dx * dx + dy * dy)
}

isTealMarker(rgb) => Bloodweb.isTealMarker(rgb)

isBlobMarker(blob) {
    if blob.Length < minBlobWidth * minBlobWidth
        return false

    xMin := 99999
    yMin := 99999
    xMax := 0
    yMax := 0
    for point in blob {
        xMin := Min(xMin, point.x)
        yMin := Min(yMin, point.y)
        xMax := Max(xMax, point.x)
        yMax := Max(yMax, point.y)
    }

    width := xMax - xMin + 1
    height := yMax - yMin + 1

    return height >= minBlobWidth and width >= minBlobWidth
}

Gdip_Shutdown(pToken)