//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

/// A Home screen stat section selectable in ``HomeSectionPicker``.
enum HomeSection: String, CaseIterable, Identifiable {
    case users
    case sessions
    case crashes

    var id: Self { self }

    var title: String {
        switch self {
        case .users: "Users"
        case .sessions: "Sessions"
        case .crashes: "Crashes"
        }
    }

    var color: Color {
        switch self {
        case .users: .green
        case .sessions: .purple
        case .crashes: .red
        }
    }

    var systemImage: String {
        switch self {
        case .users: "person.2"
        case .sessions: "clock"
        case .crashes: "exclamationmark.triangle"
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

private struct PickerPreview: View {
    @State private var selection = HomeSection.sessions

    var body: some View {
        HomeSectionPicker(selection: $selection).padding()
    }
}

#Preview {
    PickerPreview()
}
