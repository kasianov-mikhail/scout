//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct DataMismatchView: View {
    var log = Log()
    var retry: () -> Void = {}
    var copy: () -> Void = {}

    var body: some View {
        ErrorScreen {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "Data didn't match")
                    .font(.system(size: 28, weight: .bold))

                Text(verbatim: "The server answered, but Scout couldn't read the reply. The app and the server may run different Scout versions.")
                    .font(.weight450(size: 17))
                    .lineSpacing(4)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                logView
                    .padding(.top, 24)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 120)
        } actions: {
            HStack(spacing: 12) {
                Button(action: copy) {
                    Text(verbatim: "Copy log")
                }
                .buttonStyle(ErrorActionButtonStyle(role: .secondary))

                Button(action: retry) {
                    Text(verbatim: "Retry")
                }
                .buttonStyle(ErrorActionButtonStyle(role: .primary))
            }
        }
    }

    private var logView: some View {
        VStack(alignment: .leading, spacing: 0) {
            logRow(time: log.time, text: log.request, color: .secondary)
            logRow(time: log.time, text: log.response, color: .secondary)
            logRow(time: log.time, text: log.failure, color: .errorAccent)
            logRow(time: "", text: log.versions, color: Color(.systemGray))
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
    }

    private func logRow(time: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(verbatim: time)
                .foregroundStyle(Color(.systemGray))
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 64, alignment: .leading)

            Text(verbatim: text)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.weight450(size: 13, design: .monospaced))
        .lineSpacing(3)
        .padding(.vertical, 3)
    }
}

extension DataMismatchView {
    struct Log {
        var time = "14:52:41"
        var request = "POST /api/v1/records/query"
        var response = "200 OK · 412 ms · 38 KB"
        var failure = "decode Session: keyNotFound \"install_id\""
        var versions = "SDK 0.4.2 · server 0.3.9"
    }
}

#Preview("Data Mismatch") {
    NavigationStack {
        DataMismatchView()
    }
}
