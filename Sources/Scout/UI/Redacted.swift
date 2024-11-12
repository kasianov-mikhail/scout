//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A view that displays a redacted text placeholder of a specified length.
/// 
/// The `Redacted` view is used to show a placeholder text with a specified number of spaces,
/// which indicates that the actual content is not available or is being loaded.
///
/// - Parameters:
///   - length: The number of spaces to display in the redacted text.
/// 
/// - Example:
/// ```swift
/// Redacted(length: 5)
/// ```
/// This will display a redacted placeholder with a length of 5 spaces.
///
struct Redacted: View {
    let length: Int

    var body: some View {
        Text(String(repeating: " ", count: length))
            .redacted(reason: .placeholder)
    }
}

#Preview {
    List {
        Redacted(length: 3)
        Redacted(length: 5)
        Redacted(length: 8)
    }
    .listStyle(.plain)
}
