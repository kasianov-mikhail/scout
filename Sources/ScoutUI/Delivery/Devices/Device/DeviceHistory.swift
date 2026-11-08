//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

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

extension [DeviceHistoryEvent] {
    init(installs: [Install], versions: [Version], sessions: [Session]) {
        var events: [DeviceHistoryEvent] = []
        let sortedVersions = versions.sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        let versionsByInstall = Dictionary(grouping: sortedVersions, by: \.installID)
        let installedVersions = versionsByInstall.compactMapValues { $0.first?.appVersion }
        let firstVersionIDs = Set(versionsByInstall.values.compactMap { $0.first?.id })

        let datedInstalls =
            installs
            .filter { $0.date != nil }
            .sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        var isFirstInstall = true

        for install in datedInstalls {
            guard let date = install.date else {
                continue
            }
            let version = install.installID.flatMap { installedVersions[$0] }

            if isFirstInstall {
                events.append(DeviceHistoryEvent(id: "install-\(install.id)", date: date, kind: .installed(version: version)))
                isFirstInstall = false
            } else {
                events.append(DeviceHistoryEvent(id: "install-\(install.id)", date: date, kind: .reinstalled(version: version)))
            }
        }

        if datedInstalls.isEmpty, let first = sortedVersions.first, let date = first.date {
            events.append(DeviceHistoryEvent(id: "install-\(first.id)", date: date, kind: .installed(version: first.appVersion)))
        }

        for version in sortedVersions where !firstVersionIDs.contains(version.id) {
            guard let date = version.date, let appVersion = version.appVersion else {
                continue
            }
            events.append(DeviceHistoryEvent(id: "version-\(version.id)", date: date, kind: .updated(version: appVersion)))
        }

        var currentOS: String?

        for session in sessions.sorted(by: { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }) {
            guard let date = session.startDate, let osVersion = session.osVersion, !osVersion.isEmpty else {
                continue
            }
            if let currentOS, currentOS != osVersion {
                events.append(
                    DeviceHistoryEvent(
                        id: "os-\(date.timeIntervalSince1970)",
                        date: date,
                        kind: .os(from: currentOS, to: osVersion)
                    )
                )
            }
            currentOS = osVersion
        }

        self = events.sorted { $0.date > $1.date }
    }
}

private let deviceHistoryFormatter = DateFormatter(format: "MMM d")
