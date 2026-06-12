//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var criteria: FilterCriteria<Event.Level>

    init(selected: Binding<Set<Event.Level>>) {
        _criteria = StateObject(wrappedValue: FilterCriteria(selected: selected))
    }

    var body: some View {
        NavigationView {
            List(Event.Level.allCases, id: \.rawValue) { level in
                HStack {
                    Image(systemName: "circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(level.color ?? .blue)
                        .opacity(criteria.isSelected(level) ? 1 : 0)
                    Text(level.description)
                        .font(.system(size: 16))
                    Spacer()
                }
                .contentShape(Rectangle())
                .alignmentGuide(.listRowSeparatorTrailing) { dimension in
                    dimension[.trailing]
                }
                .onTapGesture {
                    criteria.toggle(level)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        criteria.reset()
                    } label: {
                        Text(verbatim: "Reset")
                    }
                    .disabled(!criteria.isResetEnabled)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        criteria.apply()
                        dismiss()
                    } label: {
                        Text(verbatim: "Apply")
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
    @Binding var levels: Set<Event.Level>

    @State private var isFilterPresented = false

    var body: some View {
        Button {
            isFilterPresented = true
        } label: {
            Text(verbatim: "Filter")
        }
        .sheet(isPresented: $isFilterPresented) {
            FilterView(selected: $levels).presentationHeight(440)
        }
        .tint(.primary)
    }
}

// MARK: - Previews

#Preview {
    FilterButton(levels: .constant([]))
}
