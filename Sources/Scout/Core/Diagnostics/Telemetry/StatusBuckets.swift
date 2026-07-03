//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

enum StatusBuckets {
    static let classes = ["2xx", "3xx", "4xx", "5xx"]

    static let dimension = "status"

    private static let categoryPrefix = "status_"

    static let categories = classes.map { categoryPrefix + $0 }

    static func category(for code: Int) -> String? {
        guard (200..<600).contains(code) else { return nil }
        return categoryPrefix + String(code / 100) + "xx"
    }

    static func category(in dimensions: [(String, String)]) -> String? {
        guard let value = dimensions.first(where: { $0.0 == dimension })?.1 else { return nil }
        guard let code = Int(value) else { return nil }
        return category(for: code)
    }

    static func index(of category: String) -> Int? {
        categories.firstIndex(of: category)
    }
}
