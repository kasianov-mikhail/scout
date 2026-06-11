//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

/// A Home screen stat section selectable in ``HomeSectionPicker``.
enum HomeSection: CaseIterable, Identifiable {
    case sessions
    case crashes
    case users

    var id: Self { self }

    var title: String {
        switch self {
        case .sessions: "Sessions"
        case .crashes: "Crashes"
        case .users: "Users"
        }
    }

    var color: Color {
        switch self {
        case .sessions: .purple
        case .crashes: .red
        case .users: .green
        }
    }

    var systemImage: String {
        switch self {
        case .sessions: "clock"
        case .crashes: "exclamationmark.triangle"
        case .users: "person.2"
        }
    }
}

/// A capsule-per-section switcher tinted with the selected section's color.
///
/// Capsules are made of Liquid Glass where available and fall back to solid
/// fills on older systems.
///
struct HomeSectionPicker: View {
    @Binding var selection: HomeSection

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 16) {
                HStack(spacing: 16) {
                    ForEach(HomeSection.allCases) { section in
                        segment(for: section)
                            .glassEffect(selection == section ? .regular.tint(section.color).interactive() : .regular.interactive())
                    }
                }
            }
        } else {
            HStack(spacing: 16) {
                ForEach(HomeSection.allCases) { section in
                    segment(for: section)
                        .background(Capsule().fill(selection == section ? section.color : Color(.systemGray6)))
                }
            }
        }
    }

    private func segment(for section: HomeSection) -> some View {
        Text(verbatim: section.title)
            .font(.subheadline.weight(selection == section ? .medium : .regular))
            .foregroundColor(selection == section ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Capsule())
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.15)) {
                    selection = section
                }
            }
    }
}

// MARK: - Previews

private struct PickerPreview: View {
    @State private var selection = HomeSection.sessions

    var body: some View {
        HomeSectionPicker(selection: $selection).padding()
    }
}

#Preview {
    PickerPreview()
}
