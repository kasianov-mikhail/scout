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
    @State private var schemaError: SchemaError?
    @Environment(\.dismiss) var dismiss

    public init(container: CKContainer) {
        self.container = container
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let schemaError {
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
            .navigationBarTitle("Home")
        }
        .task {
            await verify()
        }
        .tint(tint.value)
        .environmentObject(tint)
        .environment(\.database, container.publicCloudDatabase)
    }

    private func errorView(error: SchemaError) -> some View {
        ErrorView(error: error) {
            Task {
                await verify()
            }
        }
    }

    private func verify() async {
        do {
            try await container.verifySchema()
            schemaError = nil
        } catch let error as SchemaError {
            schemaError = error
        } catch {
            // Ignore other errors (network, auth, etc.)
        }
    }
}

#Preview("Schema Error") {
    ErrorView(
        error: SchemaError(recordTypes: ["Crash", "PeriodMatrix"]),
        retry: {}
    )
}
