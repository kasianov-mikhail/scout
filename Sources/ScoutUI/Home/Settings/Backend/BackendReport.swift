//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout

struct BackendReport {
    var statusDetail: String? = nil
    var database: String? = nil
    var schema: String? = nil
    var symbolsVersion: String? = nil
    var symbolsState: String? = nil
    var latestEvent: String? = nil
    var pendingRecords: String? = nil
    var lastSent: String? = nil
    var givenUp: String? = nil
    var lastError: String? = nil
    var storage: String? = nil
    var storageCaption: String? = nil
    var eventCount: String? = nil
    var sessionCount: String? = nil
    var metricCount: String? = nil
    var errorRate: String? = nil
    var requestCount: String? = nil
    var serverErrors: String? = nil
    var tooLarge: String? = nil
    var badKey: String? = nil
    var sendErrors: String? = nil

    var symbolsTitle: String {
        symbolsVersion.map { "Symbols \($0)" } ?? "Symbols"
    }
}

extension BackendReport {
    static func sample(engine: Backend.Engine) -> BackendReport {
        switch engine {
        case .cloudKit:
            cloudKit
        case .local, .server:
            server
        }
    }

    private static let server = BackendReport(
        statusDetail: "scout-server 0.3.9",
        symbolsVersion: "2.4.1",
        symbolsState: "Uploaded",
        latestEvent: "2 min ago",
        pendingRecords: "24",
        lastSent: "2 min ago",
        givenUp: "0",
        lastError: "none",
        storage: "4.2 GB",
        storageCaption: "18.3 M records",
        eventCount: "16.1 M",
        sessionCount: "1.4 M",
        metricCount: "0.8 M",
        errorRate: "0.4%",
        requestCount: "1,208 of 302,114 requests",
        serverErrors: "1,205",
        tooLarge: "3",
        badKey: "0"
    )

    private static let cloudKit = BackendReport(
        statusDetail: "signed in to iCloud",
        database: "Public",
        schema: "Up to date",
        symbolsVersion: "2.4.1",
        symbolsState: "Uploaded",
        latestEvent: "6 min ago",
        pendingRecords: "3",
        lastSent: "2 min ago",
        givenUp: "0",
        lastError: "none",
        storage: "~1.1 GB",
        storageCaption: "counted by Scout as it writes",
        sendErrors: "2"
    )
}
