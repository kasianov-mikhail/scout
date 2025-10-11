//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MessageView: View {
    let text: String
    let level: Message.Level

    var body: some View {

        Text(text)
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(level.color.opacity(0.2))
            .background()
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(level.color, lineWidth: 1)
            }
            .padding(.horizontal)
    }
}

#Preview {
    ForEach(Message.Level.allCases, id: \.self) { level in
        MessageView(text: level.text, level: level)
        MessageView(text: level.longText, level: level)
    }
    .padding(.vertical, 4)
}
