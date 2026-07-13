//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var criteria: FilterCriteria<EventLevel>

    init(selected: Binding<Set<EventLevel>>) {
        _criteria = StateObject(wrappedValue: FilterCriteria(selected: selected))
    }

    var body: some View {
        NavigationView {
            List(EventLevel.allCases, id: \.rawValue) { level in
                HStack {
                    Image(systemName: "circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(level.color ?? .blue)
                        .opacity(criteria.isSelected(level) ? 1 : 0)
                    Text(level.description)
                        .font(.callout)
                    Spacer()
                }
                .contentShape(Rectangle())
                .trailingRowSeparator()
                .onTapGesture {
                    criteria.toggle(level)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        criteria.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(!criteria.isResetEnabled)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        criteria.apply()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!criteria.isApplyEnabled)
                    .fontWeight(.semibold)
                }
            }
            .padding(.top)
            .listStyle(.plain)
            .scrollDisabled(true)
            .navigationTitle(en: "Filter")
            .inlineNavigationTitle()
        }
    }
}

struct FilterButton: View {
    @Binding var levels: Set<EventLevel>

    @State private var isFilterPresented = false

    var body: some View {
        Button {
            isFilterPresented = true
        } label: {
            Text(verbatim: "Filter")
        }
        .sheet(isPresented: $isFilterPresented) {
            FilterView(selected: $levels)
                .presentationHeight(440)
                .opaquePresentation()
        }
        .tint(.primary)
    }
}

extension View {
    // Gives a sheet a fixed height: a detent on iOS, an explicit golden-ratio
    // frame on macOS, where sheets have no detents.
    fileprivate func presentationHeight(_ height: CGFloat) -> some View {
        #if os(iOS)
            presentationDetents([.height(height)])
        #else
            frame(width: height / 1.618, height: height)
        #endif
    }
}

#Preview {
    FilterButton(levels: .constant([]))
}
