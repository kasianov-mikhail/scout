//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func accountWarning(_ backend: Backend) -> some View {
        modifier(AccountWarningModifier(backend: backend))
    }
}

private struct AccountWarningModifier: ViewModifier {
    let backend: Backend

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
            .alert(Text(verbatim: "iCloud Unavailable"), isPresented: $isAlertPresented) {
                Button(role: .cancel, action: {}) {
                    Text(verbatim: "OK")
                }
            } message: {
                Text(verbatim: "Sign in to iCloud to sync data.")
            }
            .task {
                await verify()
            }
            .onReceive(NotificationCenter.default.publisher(for: AppLifecycle.willEnterForeground)) { _ in
                Task {
                    await verify()
                }
            }
    }

    private func verify() async {
        warning = await backend.accountWarning()
    }
}
