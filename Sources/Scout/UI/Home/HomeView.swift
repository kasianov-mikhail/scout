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
    @State private var iCloudWarning = false
    @State private var iCloudAlertPresented = false
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
                if iCloudWarning {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            iCloudAlertPresented = true
                        } label: {
                            Image(systemName: "icloud.slash")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("iCloud Unavailable", isPresented: $iCloudAlertPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Sign in to iCloud to sync data.")
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
        let status = (try? await container.accountStatus()) ?? .couldNotDetermine
        iCloudWarning = status != .available

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

