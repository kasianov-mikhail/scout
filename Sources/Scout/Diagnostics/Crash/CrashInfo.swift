//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct CrashInfo: Codable {
    let name: String
    let reason: String?
    let stackTrace: [String]
    let date: Date
    let installID: UUID
    let launchID: UUID
    let sessionID: UUID
    let appVersion: String?

    init(name: String, reason: String?, stackTrace: [String], identity: Identity) {
        self.init(
            name: name,
            reason: reason,
            stackTrace: stackTrace,
            date: Date(),
            installID: identity.install,
            launchID: identity.launch,
            sessionID: identity.session.raw,
            appVersion: Bundle.main.marketingVersion
        )
    }

    init(
        name: String, reason: String?, stackTrace: [String], date: Date, installID: UUID, launchID: UUID,
        sessionID: UUID, appVersion: String?
    ) {
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.date = date
        self.installID = installID
        self.launchID = launchID
        self.sessionID = sessionID
        self.appVersion = appVersion
    }
}

extension IncidentArchive<CrashInfo> {
    static var crash: Self {
        IncidentArchive(folder: "Crashes", pathExtension: "crash", persist: logCrash)
    }

    // The signal handler leaves raw reports behind — symbolicating them is
    // not signal-safe, so it happens here, on the launch that finds them.
    // The converted file keeps the raw file's UUID stem: if the process dies
    // between write and remove, the next launch overwrites the same crash
    // instead of duplicating it.
    func convertRawReports() {
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return
        }

        for file in files where file.pathExtension == RawCrashFormat.pathExtension {
            if let data = try? Data(contentsOf: file), let report = RawCrashReport(data: data) {
                let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                write(report.crashInfo(), id: id)
            }
            try? fileManager.removeItem(at: file)
        }
    }
}
