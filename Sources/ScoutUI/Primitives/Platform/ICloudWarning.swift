//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func iCloudWarning(_ verify: AccessCheck?) -> some View {
        modifier(ICloudWarningModifier(verify: verify))
    }
}

private struct ICloudWarningModifier: ViewModifier {
    let verify: AccessCheck?

    @State private var issue: Backend.AccountError?
    @State private var isAlertPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                if let issue {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isAlertPresented = true
                        } label: {
                            Image(systemName: "icloud.slash").foregroundStyle(.orange)
                        }
                        .alert(Text(verbatim: issue.title), isPresented: $isAlertPresented) {
                            Button(role: .cancel, action: {}) {
                                Text(verbatim: "OK")
                            }
                        } message: {
                            Text(verbatim: issue.localizedDescription)
                        }
                    }
                }
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
        guard let verify else {
            issue = nil
            return
        }
        do {
            try await verify()
            issue = nil
        } catch {
            issue = error
        }
    }
}
