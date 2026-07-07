//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashContextSection: View {
    let crash: Crash

    var body: some View {
        if crash.sessionID != nil || crash.deviceID != nil {
            Header(title: "Context")
        }

        if let sessionID = crash.sessionID {
            Row {
                Image(systemName: "list.bullet.rectangle.portrait")
                    .frame(width: 24)
                    .foregroundStyle(.indigo)
                Text(verbatim: "Session Events")
                Spacer()
                Text(ExportFormat.shortID(sessionID))
                    .font(.footnote)
                    .monospaced()
                    .foregroundStyle(Color.gray)
            } destination: {
                SessionEventList(sessionID: sessionID)
            }
        }

        if let deviceID = crash.deviceID {
            Row {
                Image(systemName: "calendar.day.timeline.left")
                    .frame(width: 24)
                    .foregroundStyle(.blue)
                Text(verbatim: "Timeline")
                Spacer()
                Text(ExportFormat.shortID(deviceID))
                    .font(.footnote)
                    .monospaced()
                    .foregroundStyle(Color.gray)
            } destination: {
                Timeline(deviceID: deviceID, highlight: .red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            CrashContextSection(crash: .sample)
        }
        .listStyle(.plain)
    }
}
