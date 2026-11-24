//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FilterHeader: View {
    let isApplyEnabled: Bool
    let close: () -> Void
    let apply: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: close) {
                CloseGlyph()
                    .fill(Color.textPrimary)
                    .frame(width: 14, height: 14)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.surface.opacity(0.72)))
                    .overlay(Circle().strokeBorder(Color.textPrimary.opacity(0.08), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
            }
            .buttonStyle(.solid)
            .frame(width: 60)
            .accessibilityLabel(Text(verbatim: "Close"))

            Text(verbatim: "Filter")
                .font(.scoutTitle)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Button(action: apply) {
                CheckGlyph()
                    .fill(Color.textOnFill)
                    .frame(width: 18, height: 14)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.filterAccent.opacity(isApplyEnabled ? 1 : 0.35)))
                    .shadow(color: Color.filterAccent.opacity(isApplyEnabled ? 0.3 : 0), radius: 4, y: 1)
            }
            .buttonStyle(.solid)
            .frame(width: 60)
            .disabled(!isApplyEnabled)
            .accessibilityLabel(Text(verbatim: "Show Events"))
        }
        .frame(height: 52)
        .overlay(alignment: .bottom) {
            Separator()
        }
    }
}

struct FilterSection<Content: View>: View {
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
    }
}

struct FilterBox<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: .radiusBlock))
            .overlay {
                RoundedRectangle(cornerRadius: .radiusBlock)
                    .strokeBorder(Color.lineSeparator, lineWidth: 0.5)
            }
    }
}
