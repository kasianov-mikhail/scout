//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct CrashInfo: Codable {
    let name: String
    let reason: String?
    let stackTrace: [String]
    let backtrace: Backtrace?
    let date: Date
    let installID: UUID
    let launchID: UUID
    let sessionID: UUID
    let appVersion: String?

    init(name: String, reason: String?, stackTrace: [String], backtrace: Backtrace, identity: Identity) {
        self.init(
            name: name,
            reason: reason,
            stackTrace: stackTrace,
            backtrace: backtrace,
            date: Date(),
            installID: identity.install,
            launchID: identity.launch,
            sessionID: identity.session.raw,
            appVersion: Bundle.main.marketingVersion
        )
    }

    init(name: String, reason: String?, stackTrace: [String], backtrace: Backtrace?, date: Date, installID: UUID, launchID: UUID, sessionID: UUID, appVersion: String?) {
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.backtrace = backtrace
        self.date = date
        self.installID = installID
        self.launchID = launchID
        self.sessionID = sessionID
        self.appVersion = appVersion
    }
}

extension IncidentArchive<CrashInfo> {
    static var crash: Self {
        IncidentArchive(folder: "Crashes", pathExtension: "crash")
    }

    func convertRawReports() {
        for file in files where file.pathExtension == RawCrashFormat.pathExtension {
            do {
                let data = try Data(contentsOf: file)

                if let report = RawCrashReport(data: data) {
                    let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                    write(report.crashInfo, id: id)
                }
            } catch {
                print("Failed to read \(file.lastPathComponent): \(error)")
            }
            remove(file: file)
        }
    }
}

extension CrashInfo {
    func log(id: UUID = UUID(), deviceID: UUID, context: NSManagedObjectContext) throws {
        try log(
            id: id,
            deviceID: deviceID,
            idKey: "crashID",
            context: context
        ) { (entry: CrashEntry, session) in
            entry.session = session
            try session.launch?.install?.mark(name: Version.crashMarker, appVersion: appVersion)
            try session.launch?.install?.markIncident(milestone: .crash, date: entry.date)
        }
    }
}
