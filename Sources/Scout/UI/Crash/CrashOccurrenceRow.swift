//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashOccurrenceRow: View {
    let crash: Crash

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            if let date = crash.date {
                Text(verbatim: date.relativeString)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
                    .frame(width: 76, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(crash.name)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
                    .monospaced()

                HStack(spacing: 6) {
                    if let sessionID = crash.sessionID {
                        Text(verbatim: "Session \(sessionID.uuidString.prefix(4))")
                    }

                    if let launchID = crash.launchID {
                        Text(verbatim: "Launch \(launchID.uuidString.prefix(4))")
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 3)
    }
}
