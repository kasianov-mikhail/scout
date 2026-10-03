//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func iCloudWarning(_ warning: AccountWarning?) -> some View {
        modifier(ICloudWarningModifier(warning: warning))
    }
}

private struct ICloudWarningModifier: ViewModifier {
    let warning: AccountWarning?

    @State private var isAlertPresented = false
    @State private var title: String?
    @State private var description: String?

    func body(content: Content) -> some View {
        content
            .toolbar {
                if let title, let description {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isAlertPresented = true
                        } label: {
                            Image(systemName: "icloud.slash").foregroundStyle(.orange)
                        }
                        .alert(Text(verbatim: title), isPresented: $isAlertPresented) {
                            Button(role: .cancel, action: {}) {
                                Text(verbatim: "OK")
                            }
                        } message: {
                            Text(verbatim: description)
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
        guard let warning else {
            return
        }
        do {
            let accountError = try await warning()
            title = accountError?.title
            description = accountError?.errorDescription
        } catch {
            title = "iCloud Error"
            description = error.localizedDescription
        }
    }
}

extension Backend.AccountError {
    fileprivate var title: String {
        switch self {
        case .noAccount:
            "Not Signed In to iCloud"
        case .restricted:
            "iCloud Restricted"
        case .temporarilyUnavailable:
            "iCloud Temporarily Unavailable"
        case .couldNotDetermine:
            "iCloud Status Unknown"
        }
    }
}
