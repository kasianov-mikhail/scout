//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func iCloudWarning(_ warning: @escaping AccountWarning) -> some View {
        modifier(ICloudWarningModifier(warning: warning))
    }
}

private struct ICloudWarningModifier: ViewModifier {
    let warning: AccountWarning

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
        do {
            let status = try await warning()
            title = status?.title
            description = status?.description
        } catch {
            title = "iCloud Error"
            description = error.localizedDescription
        }
    }
}

extension Backend.AccountStatus {
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

    fileprivate var description: String {
        switch self {
        case .noAccount:
            "Sign in to iCloud to sync data."
        case .restricted:
            "iCloud access is restricted by parental controls or a device policy."
        case .temporarilyUnavailable:
            "Your iCloud account is temporarily unavailable. Try again later."
        case .couldNotDetermine:
            "Couldn't determine your iCloud account status. Check your connection and try again."
        }
    }
}
