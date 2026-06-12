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

/// A segmented control switching between the Home screen stat sections.
struct HomeSectionPicker: View {
    @Binding var selection: HomeSection

    var body: some View {
        Picker(selection: $selection) {
            ForEach(HomeSection.allCases) { section in
                Text(verbatim: section.title)
            }
        } label: {
            Text(verbatim: "Section")
        }
        .pickerStyle(.segmented)
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
