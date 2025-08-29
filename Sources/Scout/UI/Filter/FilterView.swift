//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var criteria: Criteria<EventLevel>

    init(selected: Binding<Set<EventLevel>>) {
        _criteria = StateObject(wrappedValue: Criteria(selected: selected))
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
                    Button("Reset") {
                        criteria.reset()
                    }
                    .disabled(!criteria.isResetEnabled)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        criteria.apply()
                        dismiss()
                    }
                    .disabled(!criteria.isApplyEnabled)
                    .fontWeight(.semibold)
                }
            }
            .padding(.top)
            .listStyle(.plain)
            .scrollDisabled(true)
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FilterButton: View {
    @Binding var levels: Set<EventLevel>

    @State private var isFilterPresented = false

    var body: some View {
        Button("Filter") {
            isFilterPresented = true
        }
        .sheet(isPresented: $isFilterPresented) {
            FilterView(selected: $levels).presentationDetents([.height(392)])
        }
        .tint(.blue)
    }
}

// MARK: - Previews

#Preview {
    FilterButton(levels: .constant([]))
}
