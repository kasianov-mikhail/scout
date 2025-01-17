//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

typealias Tint = Box<Color?>

public struct HomeView: View {
    @StateObject private var database: DatabaseController
    @StateObject private var tint = Tint(nil)
    @Environment(\.dismiss) var dismiss

    public var body: some View {
        NavigationStack {
            List {
                EventSection()
                ActiveUserSection()
                SessionSection()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle("Home")
        }
        .tint(tint.value)
        .environmentObject(tint)
        .environmentObject(database)
    }
}

// MARK: - Initializers

extension HomeView {

    /// Creates a new analytics view. The main entry point for the analytics UI.
    public init(container: CKContainer) {
        self.init(database: DatabaseController(database: container.publicCloudDatabase))
    }

    /// For testing purposes. Do not use in production.
    init() {
        self.init(database: DatabaseController(database: nil))
    }
}

#Preview {
    HomeView()
}
