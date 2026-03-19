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
    @State private var iCloudAlertPresented = false
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
                if checker.iCloudWarning {
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
        error: SchemaError(recordTypes: ["Crash", "PeriodMatrix"]),
        retry: {}
    )
}

