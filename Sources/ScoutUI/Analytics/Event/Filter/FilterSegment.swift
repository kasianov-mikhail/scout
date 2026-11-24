//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

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
                        Separator(axis: .vertical)
                    }
                }
        }
        .buttonStyle(.solid)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct CloseGlyph: Shape {
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

struct CheckGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let unit = min(rect.width / 18, rect.height / 14)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 2 * unit, y: rect.minY + 7.5 * unit))
        path.addLine(to: CGPoint(x: rect.minX + 6.5 * unit, y: rect.minY + 12 * unit))
        path.addLine(to: CGPoint(x: rect.minX + 16 * unit, y: rect.minY + 2 * unit))
        return path.strokedPath(StrokeStyle(lineWidth: 2 * unit, lineCap: .round, lineJoin: .round))
    }
}

extension Color {
    static let filterAccent = fillAccent
    static let filterDestructive = fillDanger
}
