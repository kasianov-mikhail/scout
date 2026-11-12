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
                    .font(.scoutHeadline)

                Text(verbatim: "The server answered, but Scout couldn't read the reply. The app and the server may run different Scout versions.")
                    .font(.scoutBody)
                    .lineSpacing(4)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, .space8)

                logView
                    .padding(.top, .space24)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, .gutter)
            .padding(.top, 120)
        } actions: {
            HStack(spacing: .space12) {
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
            logRow(time: log.time, text: log.failure, color: .textDanger)
            logRow(time: "", text: log.versions, color: Color.fillLevel)
        }
        .padding(.space12)
        .background(Color.surfaceGrey)
        .clipShape(RoundedRectangle(cornerRadius: .radiusBlock, style: .continuous))
    }

    private func logRow(time: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: .space8) {
            Text(verbatim: time)
                .foregroundStyle(Color.textMuted)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 64, alignment: .leading)

            Text(verbatim: text)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.scoutValue)
        .frame(height: .codeStep)
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
