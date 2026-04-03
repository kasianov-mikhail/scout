//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI
import UIKit

extension View {
    func iCloudWarning(container: CKContainer) -> some View {
        modifier(ICloudWarningModifier(container: container))
    }
}

private struct ICloudWarningModifier: ViewModifier {
    let container: CKContainer

    @State private var warning = false
    @State private var isAlertPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                if warning {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isAlertPresented = true
                        } label: {
                            Image(systemName: "icloud.slash").foregroundStyle(.orange)
                        }
                    }
                }
            }
            .alert("iCloud Unavailable", isPresented: $isAlertPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Sign in to iCloud to sync data.")
            }
            .task {
                await verify()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await verify()
                }
            }
    }

    private func verify() async {
        do {
            warning = try await container.accountStatus() != .available
        } catch {
            warning = false
        }
    }
}
