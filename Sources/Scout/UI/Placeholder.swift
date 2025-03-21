//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A SwiftUI view that serves as a placeholder.
/// 
/// This view can be used to represent a temporary or empty state in the UI.
/// 
/// Example usage:
/// ```swift
/// Placeholder(text: "No results")
/// ```
///
/// - Note: Customize this view to fit the specific needs of your application.
///
struct Placeholder: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.gray.opacity(0.7))
    }
}

#Preview {
    Placeholder(text: "No results")
}
