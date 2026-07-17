//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

@MainActor
enum ChartExportRenderer {
    static let width: CGFloat = 480

    static func data(for content: some View, format: ChartExportFormat, scale: CGFloat) -> Data? {
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(width: width, height: nil)

        switch format {
        case .png:
            renderer.scale = scale
            return pngData(from: renderer)
        case .pdf:
            return pdfData(from: renderer)
        }
    }

    private static func pngData(from renderer: ImageRenderer<some View>) -> Data? {
        #if os(iOS)
            return renderer.uiImage?.pngData()
        #else
            guard let image = renderer.nsImage, let tiff = image.tiffRepresentation,
                let bitmap = NSBitmapImageRep(data: tiff)
            else {
                return nil
            }
            return bitmap.representation(using: .png, properties: [:])
        #endif
    }

    private static func pdfData(from renderer: ImageRenderer<some View>) -> Data? {
        var data: Data?

        renderer.render { size, draw in
            let pdf = NSMutableData()
            var box = CGRect(origin: .zero, size: size)

            guard let consumer = CGDataConsumer(data: pdf as CFMutableData),
                let context = CGContext(consumer: consumer, mediaBox: &box, nil)
            else {
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
