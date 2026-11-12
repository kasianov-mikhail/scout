//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ServerOutageView: View {
    var downFor = "12 min"
    var since = "14:40"
    var historyStart = "15:00 yesterday"
    var lastAnswer = "14:40:07"
    var checksFailed = 24
    var nextCheck = "in 30 s"
    var check: () -> Void = {}

    var body: some View {
        ErrorScreen {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: .space8) {
                    Circle()
                        .fill(Color.errorAccent)
                        .frame(width: 8, height: 8)

                    Text(verbatim: "Down for \(downFor)")
                        .font(.scoutRowStrong)
                        .foregroundStyle(Color.textDanger)
                }

                Text(verbatim: "Scout server is down")
                    .font(.scoutHeadline)
                    .padding(.top, .space6)

                Text(verbatim: "No answer since \(since). Events wait on the devices and upload when it is back.")
                    .font(.scoutBody)
                    .lineSpacing(4)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space8)

                strip
                    .padding(.top, 28)

                HStack {
                    Text(verbatim: historyStart)
                    Spacer(minLength: 0)
                    Text(verbatim: "now")
                }
                .font(.scoutFootnote)
                .foregroundStyle(Color.textMuted)
                .padding(.top, .space6)

                details
                    .padding(.top, .space20)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, .gutter)
            .padding(.top, 120)
        } actions: {
            Button(action: check) {
                Text(verbatim: "Check Now")
            }
            .buttonStyle(ErrorActionButtonStyle(role: .primary))
        }
    }

    private var strip: some View {
        HStack(spacing: .space2) {
            ForEach(0..<24, id: \.self) { index in
                RoundedRectangle(cornerRadius: .radiusBar, style: .continuous)
                    .fill(index == 23 ? Color.errorAccent : Color.surfaceSkeleton)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
            }
        }
    }

    private var details: some View {
        VStack(spacing: 0) {
            detailRow(title: "Last answer", value: lastAnswer)
            detailRow(title: "Checks failed", value: String(checksFailed))
            detailRow(title: "Next check", value: nextCheck)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(verbatim: title)
                .foregroundStyle(Color.textMuted)

            Spacer(minLength: 8)

            Text(verbatim: value)
                .monospacedDigit()
        }
        .font(.scoutBody)
        .frame(height: .rowRegular)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

#Preview("Server Outage") {
    NavigationStack {
        ServerOutageView()
    }
}
