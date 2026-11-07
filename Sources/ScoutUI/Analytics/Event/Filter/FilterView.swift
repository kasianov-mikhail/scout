//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var draft: FilterDraft

    init(query: Binding<EventQuery>) {
        _draft = StateObject(wrappedValue: FilterDraft(query: query))
    }

    var body: some View {
        VStack(spacing: 0) {
            FilterHeader(isApplyEnabled: draft.isApplyEnabled, close: dismiss.callAsFunction, apply: apply)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    FilterLevelsView(draft: draft)
                    FilterPeriodView(draft: draft)
                    FilterContextView(draft: draft)
                }
                .padding(.horizontal, 16)
                .padding(.top, 22)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                resetBar
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        #if os(macOS)
            .frame(minWidth: 390, minHeight: 560)
        #endif
    }

    private var resetBar: some View {
        Button(action: draft.reset) {
            Text(verbatim: "Reset Filter")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color(.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Color(.systemGray3), lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .accessibilityLabel(Text(verbatim: "Reset Filter"))
    }

    private func apply() {
        draft.apply()
        dismiss()
    }
}

private struct FilterHeader: View {
    let isApplyEnabled: Bool
    let close: () -> Void
    let apply: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color(.systemBackground).opacity(0.72)))
                    .overlay(Circle().strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
            }
            .buttonStyle(.plain)
            .frame(width: 60)
            .accessibilityLabel(Text(verbatim: "Close"))

            Text(verbatim: "Filter")
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Button(action: apply) {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.blue.opacity(isApplyEnabled ? 1 : 0.35)))
                    .shadow(color: Color.blue.opacity(isApplyEnabled ? 0.3 : 0), radius: 4, y: 1)
            }
            .buttonStyle(.plain)
            .frame(width: 60)
            .disabled(!isApplyEnabled)
            .accessibilityLabel(Text(verbatim: "Show Events"))
        }
        .frame(height: 52)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 0.5)
        }
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(Color(.systemGray))

            content()
        }
    }
}

struct FilterBox<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(Color(.systemGray3), lineWidth: 0.5)
            }
    }
}

struct FilterSegment: View {
    let title: String
    let isSelected: Bool
    let ink: Color
    let fill: Color
    let showsDivider: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                .foregroundStyle(ink)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .background(isSelected ? fill : Color.clear)
                .overlay(alignment: .trailing) {
                    if showsDivider {
                        Rectangle()
                            .fill(Color(.systemGray3))
                            .frame(width: 0.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Filter Form") {
    FilterView(
        query: .constant(
            EventQuery(
                levels: [.error, .critical],
                sessionID: UUID()
            )
        )
    )
}
