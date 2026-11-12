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
                VStack(alignment: .leading, spacing: .space22) {
                    FilterLevelsView(draft: draft)
                    FilterPeriodView(draft: draft)
                    FilterContextView(draft: draft)
                }
                .padding(.horizontal, .gutter)
                .padding(.top, .space22)
                .padding(.bottom, .space16)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                resetBar
            }
        }
        .background(Color.surface.ignoresSafeArea())
        #if os(macOS)
            .frame(minWidth: 390, minHeight: 560)
        #endif
    }

    private var resetBar: some View {
        Button(action: draft.reset) {
            Text(verbatim: "Reset Filter")
                .font(.scoutRowStrong)
                .foregroundStyle(Color.filterDestructive)
                .frame(maxWidth: .infinity)
                .frame(height: 47)
                .background(Color.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: .radiusBlock)
                        .strokeBorder(Color.lineSeparator, lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, .gutter)
        .background(Color.surface)
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
                CloseGlyph()
                    .fill(Color.textPrimary)
                    .frame(width: 14, height: 14)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.surface.opacity(0.72)))
                    .overlay(Circle().strokeBorder(Color.textPrimary.opacity(0.08), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
            }
            .buttonStyle(.plain)
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
            .buttonStyle(.plain)
            .frame(width: 60)
            .disabled(!isApplyEnabled)
            .accessibilityLabel(Text(verbatim: "Show Events"))
        }
        .frame(height: 52)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.surfaceBarIdle)
                .frame(height: 0.5)
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

struct FilterSegment: View {
    let title: String
    let isSelected: Bool
    let ink: Color
    let fill: Color
    let showsDivider: Bool
    let alignment: Alignment
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(isSelected ? .scoutRowStrong : .scoutRow)
                .foregroundStyle(ink)
                .lineLimit(1)
                .padding(.horizontal, .space8)
                .padding(.vertical, .space8)
                .frame(maxWidth: .infinity, alignment: alignment)
                .background(isSelected ? fill : Color.clear)
                .overlay(alignment: .trailing) {
                    if showsDivider {
                        Rectangle()
                            .fill(Color.lineSeparator)
                            .frame(width: 0.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct CloseGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let unit = min(rect.width, rect.height) / 14
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 2 * unit, y: rect.minY + 2 * unit))
        path.addLine(to: CGPoint(x: rect.minX + 12 * unit, y: rect.minY + 12 * unit))
        path.move(to: CGPoint(x: rect.minX + 12 * unit, y: rect.minY + 2 * unit))
        path.addLine(to: CGPoint(x: rect.minX + 2 * unit, y: rect.minY + 12 * unit))
        return path.strokedPath(StrokeStyle(lineWidth: 2 * unit, lineCap: .round))
    }
}

private struct CheckGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let unit = min(rect.width / 18, rect.height / 14)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 2 * unit, y: rect.minY + 7.5 * unit))
        path.addLine(to: CGPoint(x: rect.minX + 6.5 * unit, y: rect.minY + 12 * unit))
        path.addLine(to: CGPoint(x: rect.minX + 16 * unit, y: rect.minY + 2 * unit))
        return path.strokedPath(StrokeStyle(lineWidth: 2 * unit, lineCap: .round, lineJoin: .round))
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
