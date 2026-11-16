import AppKit
import ImageIO
import UniformTypeIdentifiers

// Run from the project root. AppKit rasterizes the editable SVG at each
// Flutter density, so the app only needs its existing PNG decoder.
let project = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let directory = project.appendingPathComponent("assets/branding")
if CommandLine.arguments.dropFirst().first == "--form-contrast" {
    try exportLightFormContrast(in: directory)
    exit(EXIT_SUCCESS)
}
let master = try String(
    contentsOf: directory.appendingPathComponent("digigym-master.svg"),
    encoding: .utf8
)
let stackedViewport = #"width="862" height="603" viewBox="0 0 862 603""#
let stackedPreview = ##"<use id="preview" xlink:href="#stacked"/>"##
let darkInk = ##"id="digi" fill="#ffffff""##

for marker in [stackedViewport, stackedPreview, darkInk] {
    guard master.components(separatedBy: marker).count == 2 else {
        fatalError("The SVG master must contain one marker matching \(marker)")
    }
}

func exportLightFormContrast(in directory: URL) throws {
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    for scale in 1...3 {
        let variant = scale == 1 ? directory : directory.appendingPathComponent("\(scale).0x")
        let original = variant.appendingPathComponent("digigym_stacked_light.png")
        guard let source = CGImageSourceCreateWithURL(original as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            fatalError("The approved light stacked PNG is required at \(scale)x")
        }
        let padding = 3 * scale
        let width = image.width + 2 * padding
        let height = image.height + 2 * padding
        guard let canvas = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            fatalError("Unable to create form contrast export at \(scale)x")
        }
        let frame = CGRect(x: padding, y: padding, width: image.width, height: image.height)
        canvas.interpolationQuality = .none
        canvas.draw(image, in: frame)
        let pixels = canvas.data!.assumingMemoryBound(to: UInt8.self)
        var dumbbell = [Double](repeating: 0, count: width * height)
        var gym = dumbbell
        // The split lines land in fully transparent gaps of the stacked logo.
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = (y + padding) * width + x + padding
                let alpha = Double(pixels[index * 4 + 3]) / 255
                if Double(y) < Double(image.height) * 0.64 {
                    dumbbell[index] = alpha
                } else if Double(x) > Double(image.width) * 0.465 {
                    gym[index] = alpha
                }
            }
        }
        let iconShadow = blurMask(dumbbell, width: width, height: height,
                                  sigma: 0.65 * Double(scale), offset: 0.45 * Double(scale))
        let wordShadow = blurMask(gym, width: width, height: height,
                                  sigma: 0.52 * Double(scale), offset: 0.42 * Double(scale))
        // Composite neutral ink behind the approved pixels. An opaque artwork
        // pixel keeps its exact original color, while edge pixels retain coverage.
        for i in 0..<(width * height) {
            let alpha = Double(pixels[i * 4 + 3]) / 255
            let shadow = 1 - (1 - 0.20 * iconShadow[i]) * (1 - 0.48 * wordShadow[i])
            let contribution = (1 - alpha) * shadow
            let neutral = Int((38 * contribution).rounded())
            for channel in 0..<3 {
                pixels[i * 4 + channel] += UInt8(neutral)
            }
            pixels[i * 4 + 3] = UInt8((255 * (alpha + contribution)).rounded())
        }
        let target = variant.appendingPathComponent("digigym_stacked_light_form.png")
        guard let png = CGImageDestinationCreateWithURL(
            target as CFURL, UTType.png.identifier as CFString, 1, nil
        ), let rendered = canvas.makeImage() else {
            fatalError("Unable to write \(target.path)")
        }
        CGImageDestinationAddImage(png, rendered, nil)
        guard CGImageDestinationFinalize(png) else {
            fatalError("Unable to finalize \(target.path)")
        }
        print("\(target.lastPathComponent) at \(scale)x — \(width) × \(height)")
    }
}

let layouts = [
    ("stacked", 228, 160, "0 0 862 603"),
    ("horizontal", 154, 21, "0 0 153.5852596 20.9577889"),
]
let themeInks = [("dark", "#ffffff"), ("light", "#18211d")]

for (layout, logicalWidth, logicalHeight, viewBox) in layouts {
    for (theme, ink) in themeInks {
        for scale in 1...3 {
            let width = logicalWidth * scale
            let height = logicalHeight * scale
            let svg = master
                .replacingOccurrences(
                    of: stackedViewport,
                    with: "width=\"\(width)\" height=\"\(height)\" viewBox=\"\(viewBox)\""
                )
                .replacingOccurrences(
                    of: stackedPreview,
                    with: "<use id=\"preview\" xlink:href=\"#\(layout)\"/>"
                )
                .replacingOccurrences(of: darkInk, with: "id=\"digi\" fill=\"\(ink)\"")
            guard let image = NSImage(data: Data(svg.utf8)),
                  let canvas = CGContext(
                      data: nil, width: width, height: height,
                      bitsPerComponent: 8, bytesPerRow: width * 4,
                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                  ) else {
                fatalError("Unable to rasterize \(layout) \(theme) at \(scale)x")
            }
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            canvas.clear(frame)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(cgContext: canvas, flipped: false)
            image.draw(in: frame)
            NSGraphicsContext.restoreGraphicsState()

            let variant = scale == 1 ? directory : directory.appendingPathComponent("\(scale).0x")
            try FileManager.default.createDirectory(at: variant, withIntermediateDirectories: true)
            let target = variant.appendingPathComponent("digigym_\(layout)_\(theme).png")
            guard let png = CGImageDestinationCreateWithURL(
                target as CFURL, UTType.png.identifier as CFString, 1, nil
            ), let rendered = canvas.makeImage() else {
                fatalError("Unable to write \(target.path)")
            }
            CGImageDestinationAddImage(png, rendered, nil)
            guard CGImageDestinationFinalize(png) else {
                fatalError("Unable to finalize \(target.path)")
            }
            print("\(target.lastPathComponent) at \(scale)x — \(width) × \(height)")
        }
    }
}


// A separable Gaussian smooths the shadow mask only. The fractional offset is
// included in the vertical kernel so the result is consistent across densities.
func blurMask(
    _ mask: [Double], width: Int, height: Int, sigma: Double, offset: Double
) -> [Double] {
    func weights(offset: Double) -> [(Int, Double)] {
        let radius = Int(ceil(3 * sigma + abs(offset)))
        let raw = (-radius...radius).map { i in
            let distance = (Double(i) - offset) / sigma
            return (i, exp(-0.5 * distance * distance))
        }
        let sum = raw.reduce(0.0) { $0 + $1.1 }
        return raw.map { ($0.0, $0.1 / sum) }
    }

    let horizontal = weights(offset: 0)
    let vertical = weights(offset: offset)
    var intermediate = [Double](repeating: 0, count: mask.count)
    var output = intermediate
    for y in 0..<height {
        for x in 0..<width {
            for (delta, weight) in horizontal where x - delta >= 0 && x - delta < width {
                intermediate[y * width + x] += weight * mask[y * width + x - delta]
            }
        }
    }
    for y in 0..<height {
        for x in 0..<width {
            for (delta, weight) in vertical where y - delta >= 0 && y - delta < height {
                output[y * width + x] += weight * intermediate[(y - delta) * width + x]
            }
        }
    }
    return output
}
