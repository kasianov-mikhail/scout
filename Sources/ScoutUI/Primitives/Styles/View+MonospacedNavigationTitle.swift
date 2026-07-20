//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

extension View {
    func monospacedNavigationTitle(en title: String) -> some View {
        navigationTitle(en: title)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(verbatim: title)
                        .font(.system(.headline, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
    }
}
