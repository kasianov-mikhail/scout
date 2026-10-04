//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func iCloudWarning(_ verify: (@Sendable () async throws -> Void)?, issue: Binding<ICloudIssue?>) -> some View {
        modifier(ICloudWarningModifier(verify: verify, issue: issue))
    }
}

private struct ICloudWarningModifier: ViewModifier {
    let verify: (@Sendable () async throws -> Void)?

    @Binding var issue: ICloudIssue?
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
                            Text(verbatim: issue.message)
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
        } catch let error as Backend.AccountError {
            issue = .account(error)
        } catch {
            issue = .failure(error)
        }
    }
}
