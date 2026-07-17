//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import ScoutCore

struct ChartExportFile {
    let data: Data
    let name: String
    let format: ChartExportFormat

    var filename: String {
        let trimmed = name.replacingOccurrences(of: "/", with: "-").trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.count > 0 ? trimmed : "Chart"
        return "\(base).\(format.fileExtension)"
    }

    func write() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }
}
