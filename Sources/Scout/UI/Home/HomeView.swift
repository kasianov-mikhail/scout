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
    @StateObject private var checker = HomeChecker()
    @Environment(\.dismiss) var dismiss

    public init(container: CKContainer) {
        self.container = container
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let schemaError = checker.schemaError {
                    errorView(error: schemaError)
                } else {
                    HomeContent()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .iCloudWarning(checker.iCloudWarning)
            .navigationBarTitle("Home")
        }
        .task {
            await checker.verify(container: container)
        }
        .tint(tint.value)
        .environmentObject(tint)
        .environment(\.database, container.publicCloudDatabase)
    }

    private func errorView(error: SchemaError) -> some View {
        ErrorView(error: error) {
            Task {
                await checker.verify(container: container)
            }
        }
    }
}

#Preview("Schema Error") {
    ErrorView(
        error: SchemaError(recordTypes: [CrashObject.recordType, PeriodCell<Int>.recordType]),
        retry: {}
    )
}
