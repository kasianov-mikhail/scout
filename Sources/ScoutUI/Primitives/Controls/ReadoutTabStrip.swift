//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReadoutTabStrip<Value, Content: View, Indicator: View>: View {
    let values: [Value]
    let isSelected: (Value) -> Bool
    let isLoading: Bool
    var spacing: CGFloat = .space12
    var showsDividers = false
    let onSelect: ((Value) -> Void)?
    let indicator: (Value) -> Indicator
    let content: (Value, Bool) -> Content

    init(values: [Value], isSelected: @escaping (Value) -> Bool, isLoading: Bool, spacing: CGFloat = .space12, showsDividers: Bool = false, onSelect: ((Value) -> Void)?, @ViewBuilder indicator: @escaping (Value) -> Indicator, @ViewBuilder content: @escaping (Value, Bool) -> Content) {
        self.values = values
        self.isSelected = isSelected
        self.isLoading = isLoading
        self.spacing = spacing
        self.showsDividers = showsDividers
        self.onSelect = onSelect
        self.indicator = indicator
        self.content = content
    }

    init(values: [Value], isSelected: @escaping (Value) -> Bool, isLoading: Bool, spacing: CGFloat = .space12, showsDividers: Bool = false, onSelect: ((Value) -> Void)?, @ViewBuilder content: @escaping (Value, Bool) -> Content) where Indicator == EmptyView {
        self.init(
            values: values,
            isSelected: isSelected,
            isLoading: isLoading,
            spacing: spacing,
            showsDividers: showsDividers,
            onSelect: onSelect,
            indicator: { _ in EmptyView() },
            content: content
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                cell(value, index: index)
            }
        }
        .background(alignment: .bottom) {
            Separator()
        }
    }

    @ViewBuilder
    private func cell(_ value: Value, index: Int) -> some View {
        let selected = isSelected(value)
        let isActive = !isLoading && selected
        let isLast = index == values.count - 1
        let padded = content(value, isActive)
            .padding(.leading, index == 0 ? 0 : (showsDividers ? .space10 : 0))
            .padding(.trailing, isLast ? 0 : (showsDividers ? .space10 : 0))
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                if isActive {
                    indicator(value)
                }
            }

        Group {
            if let onSelect {
                Button {
                    onSelect(value)
                } label: {
                    padded
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            } else {
                padded
            }
        }
        .overlay(alignment: .trailing) {
            if showsDividers, !isLast {
                Separator(axis: .vertical)
            }
        }
    }
}
