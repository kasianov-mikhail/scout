//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ImageIO
import SwiftUI
import Testing

@testable import ScoutUI

@MainActor
struct ChartExportRendererTests {
    @Test("Renders PNG data") func testPNG() {
        let data = ChartExportRenderer.data(for: Text(verbatim: "Chart"), format: .png, scale: 2)

        #expect(data?.prefix(4) == Data([0x89, 0x50, 0x4E, 0x47]))
    }

    @Test("Renders PNG upright at the export scale") func testPNGLayout() throws {
        let content = VStack(spacing: 0) {
            Color(red: 1, green: 0, blue: 0).frame(height: 10)
            Color(red: 0, green: 0, blue: 1).frame(height: 10)
        }

        let data = try #require(ChartExportRenderer.data(for: content, format: .png, scale: 2))
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))

        #expect(image.width == 960)
        #expect(image.height == 40)

        let top = image.pixel(x: 480, y: 0)
        #expect(top[0] > 200 && top[2] < 50)

        let bottom = image.pixel(x: 480, y: 39)
        #expect(bottom[0] < 50 && bottom[2] > 200)
    }

    @Test("Renders PDF data") func testPDF() {
        let data = ChartExportRenderer.data(for: Text(verbatim: "Chart"), format: .pdf, scale: 2)

        let header = data.map { String(decoding: $0.prefix(4), as: UTF8.self) }
        #expect(header == "%PDF")
    }
}

extension CGImage {
    fileprivate func pixel(x: Int, y: Int) -> [UInt8] {
        var pixel = [UInt8](repeating: 0, count: 4)

        pixel.withUnsafeMutableBytes { buffer in
            let context = CGContext(data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            context?.draw(self, in: CGRect(x: -x, y: y - height + 1, width: width, height: height))
        }

        return pixel
    }
}
