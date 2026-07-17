//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

// Design-exploration primitive: a modal range picker. Not yet wired into the app.

struct RangeSheet: View {
    var style: CalendarStyle = .capsule

    @Binding var selection: Range<Date>?

    @Environment(\.dismiss) private var dismiss

    @State private var month = CalendarMonth()
    @State private var range = DateRangeSelection()

    var body: some View {
        VStack(spacing: 20) {
            header
            grid
            Spacer(minLength: 0)
            footer
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    @ViewBuilder
    private var grid: some View {
        switch style {
        case .capsule: ConnectedMonthGrid(month: month, selection: $range)
        case .cell: TintedMonthGrid(month: month, selection: $range)
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            MonthChevron(image: "chevron.left") { step(-1) }
            Text(verbatim: month.shortTitle)
                .font(.callout)
                .monospaced()
                .frame(maxWidth: .infinity)
            MonthChevron(image: "chevron.right") { step(1) }
        }
        .frame(height: 44)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text(verbatim: "Cancel").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(action: apply) {
                Text(verbatim: "Apply").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(range.range == nil)
        }
        .controlSize(.large)
        .font(.callout.weight(.semibold))
    }

    private func apply() {
        guard let applied = range.range else {
            return
        }
        selection = applied
        dismiss()
    }

    private func step(_ delta: Int) {
        month = CalendarMonth(containing: month.month.addingMonth(delta))
    }
}

private struct RangeSheetPreviewHost: View {
    @State private var activeStyle: CalendarStyle?
    @State private var selection: Range<Date>?

    var body: some View {
        VStack(spacing: 16) {
            Button {
                activeStyle = .capsule
            } label: {
                Text(verbatim: "Capsule range")
            }
            .buttonStyle(.borderedProminent)

            Button {
                activeStyle = .cell
            } label: {
                Text(verbatim: "Cell range")
            }
            .buttonStyle(.borderedProminent)

            if let selection {
                let lower = selection.lowerBound.formatted(date: .abbreviated, time: .omitted)
                let upper = selection.upperBound.formatted(date: .abbreviated, time: .omitted)
                Text(verbatim: "\(lower) – \(upper)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .sheet(item: $activeStyle) { style in
            RangeSheet(style: style, selection: $selection)
                .presentationDetents([.height(540)])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview("Range picker") { RangeSheetPreviewHost() }
