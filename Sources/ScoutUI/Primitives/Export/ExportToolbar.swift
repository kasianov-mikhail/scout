//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func exportToolbar(text: String?, tint: Color? = nil) -> some View {
        modifier(ExportToolbar(text: text, tint: tint))
    }
}

private struct ExportToolbar: ViewModifier {
    let text: String?
    let tint: Color?

    @State private var message: Message?

    func body(content: Content) -> some View {
        content
            .toolbar {
                if let text {
                    ToolbarItemGroup(placement: .bottomBar) {
                        ShareLink(item: text)
                            .tint(optional: tint)
                        CopyButton(text: text, message: $message)
                            .tint(optional: tint)
                        Spacer()
                    }
                }
            }
            .message($message)
    }
}

extension View {
    @ViewBuilder fileprivate func tint(optional color: Color?) -> some View {
        if let color {
            tint(color)
        } else {
            self
        }
    }
}

#Preview {
    NavigationStack {
        Text(verbatim: "Content")
            .navigationTitle(en: "Export Toolbar")
            .inlineNavigationTitle()
            .exportToolbar(text: "Exported text")
    }
}
