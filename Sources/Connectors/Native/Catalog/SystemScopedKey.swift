//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// A value paired with an optional system, serialized as `value|system`.
struct SystemScopedKey {
    let value: String
    let system: String?

    init(value: String, system: String?) {
        self.value = value
        self.system = system
    }

    init?(key: String) {
        let parts = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)

        guard let value = parts.first else {
            return nil
        }
        guard !value.isEmpty else {
            return nil
        }

        self.init(value: String(value), system: parts.count > 1 && !parts[1].isEmpty ? String(parts[1]) : nil)
    }

    var key: String {
        [value, system ?? ""].joined(separator: "|")
    }
}
