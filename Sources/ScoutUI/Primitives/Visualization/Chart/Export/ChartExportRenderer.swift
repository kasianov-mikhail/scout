//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

@MainActor
enum ChartExportRenderer {
    static let width: CGFloat = 480

    static func data(for content: some View, format: ChartExportFormat, scale: CGFloat) -> Data? {
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(width: width, height: nil)

        return switch format {
        case .png:
            renderer.pngData(scale: scale)
        case .pdf:
            renderer.pdfData
        }
    }
}
