//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func iCloudWarning(_ isPresented: Bool) -> some View {
        modifier(ICloudWarningModifier(isWarning: isPresented))
    }
}

private struct ICloudWarningModifier: ViewModifier {
    let isWarning: Bool

    @State private var isAlertPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                if isWarning {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isAlertPresented = true
                        } label: {
                            Image(systemName: "icloud.slash")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .alert("iCloud Unavailable", isPresented: $isAlertPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Sign in to iCloud to sync data.")
            }
    }
}
