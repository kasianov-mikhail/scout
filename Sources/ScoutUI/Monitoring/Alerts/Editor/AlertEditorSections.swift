//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct AlertSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: .space8) {
            Text(verbatim: title.uppercased())
                .font(.scoutFootnoteStrong)
                .tracking(0.3)
                .foregroundStyle(Color.textMuted)

            content()
        }
        .padding(.top, .space22)
    }
}

struct AlertCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: .radiusBlock))
            .overlay {
                RoundedRectangle(cornerRadius: .radiusBlock)
                    .stroke(Color.separator, lineWidth: 0.5)
            }
    }
}

struct AlertFooter: View {
    var body: some View {
        Text(footerText)
            .font(.scoutCaption)
            .lineSpacing(2)
            .foregroundStyle(Color.textMuted)
            .padding(.top, .space4)
    }

    private var footerText: AttributedString {
        var text = AttributedString("Alerts for your whole team and Slack come with Hosted Scout. ")
        var link = AttributedString("Learn more")
        link.link = URL(string: "https://github.com/kasianov-mikhail/scout-server")
        link.foregroundColor = .textLink
        text.append(link)
        return text
    }
}

struct AlertCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.scoutCaptionStrong)
        }
        .foregroundStyle(Color.textPrimary)
        .accessibilityLabel(Text(verbatim: "Close"))
    }
}

struct AlertSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.scoutRowStrong)
        }
        .disabled(!isEnabled)
        .accessibilityLabel(Text(verbatim: "Save"))
    }
}
