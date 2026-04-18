//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

extension View {
    func schemaWarning(container: CKContainer) -> some View {
        modifier(SchemaWarningModifier(container: container))
    }
}

private struct SchemaWarningModifier: ViewModifier {
    let container: CKContainer

    @State private var schemaError: SchemaError?
    @State private var isAlertPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                if schemaError != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isAlertPresented = true
                        } label: {
                            Image(systemName: "exclamationmark.icloud")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .alert("Schema Outdated", isPresented: $isAlertPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                if let schemaError {
                    Text(schemaError.errorDescription ?? "")
                }
            }
            .task {
                await verify()
            }
    }

    private func verify() async {
        do {
            try await container.verifySchema()
        } catch let error as SchemaError {
            schemaError = error
        } catch {}
    }
}
