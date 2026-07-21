//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

protocol SessionContext {
    var sessionID: UUID? { get }
    var deviceID: UUID? { get }
}

struct ContextSection<Context: SessionContext>: View {
    let context: Context
    var timelineHighlight: Color = .accentColor

    var body: some View {
        if context.sessionID != nil || context.deviceID != nil {
            Header(title: "Context")
        }

        if let sessionID = context.sessionID {
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
                SessionInspector(sessionID: sessionID, deviceID: context.deviceID)
            }
        }

        if let deviceID = context.deviceID {
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
                Timeline(deviceID: deviceID, highlight: timelineHighlight)
            }
        }
    }
}

#Preview {
    struct Sample: SessionContext {
        let sessionID: UUID?
        let deviceID: UUID?
    }

    return NavigationStack {
        InsetList {
            ContextSection(context: Sample(sessionID: UUID(), deviceID: UUID()), timelineHighlight: .red)
        }
    }
}
