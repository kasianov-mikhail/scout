//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ErrorScreen<Content: View, Actions: View>: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                actions()
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .inlineNavigationTitle()
    }
}

struct ErrorActionButtonStyle: ButtonStyle {
    enum Role {
        case primary
        case secondary
    }

    let role: Role

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }

    private var foreground: Color {
        switch role {
        case .primary:
            .white
        case .secondary:
            .primary
        }
    }

    private var background: Color {
        switch role {
        case .primary:
            .blue
        case .secondary:
            Color(red: 0xEE / 255, green: 0xEE / 255, blue: 0xF0 / 255)
        }
    }
}

extension Color {
    static let errorAccent = Color(red: 0xD7 / 255, green: 0x00 / 255, blue: 0x15 / 255)
}
