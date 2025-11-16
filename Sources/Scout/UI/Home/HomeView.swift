//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

public struct HomeView: View {
    let container: CKContainer

    @StateObject private var tint = Tint()
    @Environment(\.dismiss) var dismiss

    public init(container: CKContainer) {
        self.container = container
    }

    public var body: some View {
        NavigationStack {
            List {
                LogSection()
                ActivitySection()
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
        .environment(\.database, container.publicCloudDatabase)
    }
}
