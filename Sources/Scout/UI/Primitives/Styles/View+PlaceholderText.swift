//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func placeholderTextStyle() -> some View {
        font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.gray.opacity(0.7))
    }
}
