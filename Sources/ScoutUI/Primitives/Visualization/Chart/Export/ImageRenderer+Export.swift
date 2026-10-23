//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ImageIO
import SwiftUI
import UniformTypeIdentifiers

@MainActor
extension ImageRenderer {
    func pngData(scale: CGFloat) -> Data? {
        var data: Data?

        render(rasterizationScale: scale) { size, draw in
            let pixelWidth = Int((size.width * scale).rounded(.up))
            let pixelHeight = Int((size.height * scale).rounded(.up))

            guard let space = CGColorSpace(name: CGColorSpace.sRGB) else {
                return
            }
            guard let context = CGContext(data: nil, width: pixelWidth, height: pixelHeight, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                return
            }

            context.scaleBy(x: scale, y: scale)
            draw(context)

            guard let image = context.makeImage() else {
                return
            }

            let png = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(png as CFMutableData, UTType.png.identifier as CFString, 1, nil) else {
                return
            }

            CGImageDestinationAddImage(destination, image, nil)
            if CGImageDestinationFinalize(destination) {
                data = png as Data
            }
        }

        return data
    }

    var pdfData: Data? {
        var data: Data?

        render { size, draw in
            let pdf = NSMutableData()
            var box = CGRect(origin: .zero, size: size)

            guard let consumer = CGDataConsumer(data: pdf as CFMutableData), let context = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                return
            }

            context.beginPDFPage(nil)
            draw(context)
            context.endPDFPage()
            context.closePDF()
            data = pdf as Data
        }

        return data
    }
}
