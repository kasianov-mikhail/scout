import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count == 4, ["light", "dark"].contains(args[3]) else {
    FileHandle.standardError.write(Data("usage: frame <input> <output.png> <light|dark>\n".utf8))
    exit(64)
}
let input = args[1], output = args[2], dark = args[3] == "dark"

guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: input) as CFURL, nil),
    let image = CGImageSourceCreateImageAtIndex(src, 0, nil)
else { fatalError("read failed") }

// 1 CSS px of GitHub's box border, 6 CSS px of its corner radius, drawn at 4 px per CSS px
// for a 240 px wide image.
let scale: CGFloat = 4
let width: CGFloat = 240 * scale
let height = (CGFloat(image.height) * width / CGFloat(image.width)).rounded()
let radius = 6 * scale
let border = 1 * scale
let space = CGColorSpace(name: CGColorSpace.sRGB)!

let ctx = CGContext(
    data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0,
    space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.interpolationQuality = .high

let rect = CGRect(x: 0, y: 0, width: width, height: height)

ctx.saveGState()
ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
ctx.clip()
ctx.draw(image, in: rect)
ctx.restoreGState()

// GitHub's muted divider: #d1d9e0 / #3d444d at 70 % over white / #0d1117.
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
