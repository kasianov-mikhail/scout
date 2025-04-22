//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A view that displays a redacted text representation.
///
/// This view is used to show a placeholder text with a specified number of spaces,
/// indicating that the actual content is not available or is being loaded.
///
/// - Parameters:
///  - count: The number of spaces to display in the redacted text.
///
struct RedactedText: View {
    let count: Int?

    var body: some View {
        if let count = count {
            Text(count == 0 ? "—" : "\(count)")
        } else {
            Redacted(length: 5)
        }
    }
}
