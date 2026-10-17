//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct CrashThreadsSection: View {
    let threads: [CrashThread]

    var body: some View {
        let rows = threads.otherRows

        if !rows.isEmpty {
            Header(title: "Other Threads") {
                Text(verbatim: "\(rows.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ForEach(rows) { row in
                Row {
                    Text(verbatim: row.name)
                        .font(.callout)

                    Spacer()

                    Text(verbatim: row.frameCount)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } destination: {
                    InsetList {
                        StackTraceSection(frames: row.frames, caption: "Unsymbolicated")
                    }
                    .navigationTint(.red)
                    .monospacedNavigationTitle(en: row.name)
                }
            }
        }
    }
}

struct CrashThreadRow: Identifiable {
    let id: Int
    let frames: [String]

    var name: String {
        "Thread \(id)"
    }

    var frameCount: String {
        frames.count == 1 ? "1 frame" : "\(frames.count) frames"
    }
}

extension [CrashThread] {
    var otherRows: [CrashThreadRow] {
        enumerated()
            .filter { !$0.element.crashed }
            .map { CrashThreadRow(id: $0.offset, frames: $0.element.frames) }
    }
}

extension CrashThread: Fixture {
    static let samples: [CrashThread] = [
        CrashThread(crashed: false, frames: ["0   libsystem_kernel.dylib   + 0x1a2c", "1   libsystem_pthread.dylib   + 0x3f8"]),
        CrashThread(crashed: true, frames: ["0   MyApp   + 0x1a2f0"]),
        CrashThread(crashed: false, frames: ["0   libsystem_kernel.dylib   + 0x1b44"]),
    ]
}

#Preview {
    NavigationStack {
        InsetList {
            CrashThreadsSection(threads: .samples)
        }
    }
}
