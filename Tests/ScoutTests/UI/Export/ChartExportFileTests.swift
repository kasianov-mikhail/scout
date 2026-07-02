//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

struct ChartExportFileTests {
    @Test("Filename joins name and extension") func testFilename() {
        let file = ChartExportFile(data: Data(), name: "app_launch", format: .png)

        #expect(file.filename == "app_launch.png")
    }

    @Test("Filename sanitizes slashes and whitespace") func testSanitizedFilename() {
        let file = ChartExportFile(data: Data(), name: "  a/b  ", format: .pdf)

        #expect(file.filename == "a-b.pdf")
    }

    @Test("Filename falls back for an empty name") func testEmptyName() {
        let file = ChartExportFile(data: Data(), name: "   ", format: .png)

        #expect(file.filename == "Chart.png")
    }

    @Test("Write stores the data at the returned URL") func testWrite() throws {
        let data = Data([1, 2, 3])
        let file = ChartExportFile(data: data, name: "export-test", format: .png)

        let url = try file.write()
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(url.lastPathComponent == "export-test.png")
        #expect(try Data(contentsOf: url) == data)
    }
}
