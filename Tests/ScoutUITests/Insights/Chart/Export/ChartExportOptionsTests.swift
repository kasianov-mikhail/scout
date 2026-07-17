//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI
import Testing

@testable import ScoutCore
@testable import ScoutUI

struct ChartExportOptionsTests {
    @Test("PNG file extension") func testPNGExtension() {
        #expect(ChartExportFormat.png.fileExtension == "png")
    }

    @Test("PDF file extension") func testPDFExtension() {
        #expect(ChartExportFormat.pdf.fileExtension == "pdf")
    }

    @Test("System appearance keeps the current scheme") func testSystemScheme() {
        #expect(ChartExportAppearance.system.resolvedScheme(current: .dark) == .dark)
        #expect(ChartExportAppearance.system.resolvedScheme(current: .light) == .light)
    }

    @Test("Light appearance overrides the current scheme") func testLightScheme() {
        #expect(ChartExportAppearance.light.resolvedScheme(current: .dark) == .light)
    }

    @Test("Dark appearance overrides the current scheme") func testDarkScheme() {
        #expect(ChartExportAppearance.dark.resolvedScheme(current: .light) == .dark)
    }

    @Test("Defaults include the full header as PNG") func testDefaults() {
        let options = ChartExportOptions()

        #expect(options.format == .png)
        #expect(options.appearance == .system)
        #expect(options.includesTitle)
        #expect(options.includesRange)
    }
}
