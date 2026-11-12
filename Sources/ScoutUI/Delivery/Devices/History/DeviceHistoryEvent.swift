//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct DeviceHistoryEvent: Identifiable {
    enum Kind {
        case installed(version: String?)
        case reinstalled(version: String?)
        case updated(version: String)
        case os(from: String, to: String)
    }

    let id: String
    let date: Date
    let kind: Kind

    var title: String {
        switch kind {
        case .installed(let version):
            version == nil ? "First seen" : "First seen with"
        case .reinstalled(let version):
            version == nil ? "Reinstalled" : "Reinstalled with"
        case .updated:
            "Updated to"
        case .os(let from, let to):
            osTitle(from: from, to: to)
        }
    }

    private func osTitle(from: String, to: String) -> String {
        let parts = from.split(separator: " ", maxSplits: 1)
        guard parts.count == 2 else {
            return "\(from) → \(to)"
        }
        let prefix = "\(parts[0]) "
        guard to.hasPrefix(prefix) else {
            return "\(from) → \(to)"
        }
        return "\(from) → \(to.dropFirst(prefix.count))"
    }

    var version: String? {
        switch kind {
        case .installed(let version), .reinstalled(let version):
            version
        case .updated(let version):
            version
        case .os:
            nil
        }
    }

    var dateText: String {
        deviceHistoryFormatter.string(from: date)
    }
}

private let deviceHistoryFormatter = DateFormatter(format: "MMM d")
