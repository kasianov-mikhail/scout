//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI
import Testing

@testable import Scout

@MainActor
struct ChartExportRendererTests {
    @Test("Renders PNG data") func testPNG() {
        let data = ChartExportRenderer.data(for: Text(verbatim: "Chart"), format: .png, scale: 2)

        #expect(data?.prefix(4) == Data([0x89, 0x50, 0x4E, 0x47]))
    }

    @Test("Renders PDF data") func testPDF() {
        let data = ChartExportRenderer.data(for: Text(verbatim: "Chart"), format: .pdf, scale: 2)

        let header = data.map { String(decoding: $0.prefix(4), as: UTF8.self) }
        #expect(header == "%PDF")
    }
}
