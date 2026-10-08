import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count == 4, ["light", "dark"].contains(args[3]) else {
    FileHandle.standardError.write(Data("usage: frame-logo <input> <output.png> <light|dark>\n".utf8))
    exit(64)
}
let input = args[1], output = args[2], dark = args[3] == "dark"

guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: input) as CFURL, nil),
    let source = CGImageSourceCreateImageAtIndex(src, 0, nil)
else { fatalError("read failed") }

let space = CGColorSpace(name: CGColorSpace.sRGB)!

// The original logo has a gray border baked in at 1 px from each edge. Cut it off.
let trim = 6
let image = source.cropping(to: CGRect(x: trim, y: trim, width: source.width - 2 * trim, height: source.height - 2 * trim))!
let w = image.width, h = image.height

var pixels = [UInt8](repeating: 0, count: w * h * 4)
let read = CGContext(
    data: &pixels, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
    space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
read.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))

// Dark theme: every pixel is white mixed with one ink, either the blue mark or the navy text.
// Recover the coverage, then mix the same coverage into the dark background, with a light text ink.
let background: [Double] = dark ? [0x0d, 0x11, 0x17] : [255, 255, 255]
if dark {
    let blue: [Double] = [56, 114, 240], navy: [Double] = [14, 42, 57], text: [Double] = [0xe6, 0xed, 0xf3]
    for i in 0..<(w * h) {
        let r = Double(pixels[i * 4]), b = Double(pixels[i * 4 + 2])
        let coverage: Double, ink: [Double]
        if (255 - b) < (255 - r) * 0.5 {
            coverage = (255 - r) / (255 - blue[0]); ink = blue
        } else {
            coverage = (255 - r) / (255 - navy[0]); ink = text
        }
        let a = min(max(coverage, 0), 1)
        for c in 0..<3 { pixels[i * 4 + c] = UInt8((background[c] + a * (ink[c] - background[c])).rounded()) }
    }
}
let art = read.makeImage()!

// 1 CSS px of GitHub's box border, 6 CSS px of its corner radius, at 4 px per CSS px
// for a 774 px wide image, the content width of the README box.
let scale: CGFloat = 4
let width: CGFloat = 774 * scale
let height = (CGFloat(h) * width / CGFloat(w)).rounded()
let radius = 6 * scale
let border = 1 * scale

let ctx = CGContext(
    data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0,
    space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.interpolationQuality = .high

let rect = CGRect(x: 0, y: 0, width: width, height: height)

ctx.saveGState()
ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
ctx.clip()
ctx.draw(art, in: rect)
ctx.restoreGState()

let inset = rect.insetBy(dx: border / 2, dy: border / 2)
ctx.addPath(CGPath(roundedRect: inset, cornerWidth: radius - border / 2, cornerHeight: radius - border / 2, transform: nil))
ctx.setStrokeColor(
    dark
        ? CGColor(srgbRed: 0x2f / 255, green: 0x35 / 255, blue: 0x3d / 255, alpha: 1)
        : CGColor(srgbRed: 0xdf / 255, green: 0xe4 / 255, blue: 0xe9 / 255, alpha: 1))
ctx.setLineWidth(border)
ctx.strokePath()

let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: output) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
CGImageDestinationFinalize(dest)
