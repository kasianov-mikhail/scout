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
                    .padding(.horizontal, .gutter)
                    .padding(.top, .space10)
                    .background(Color.surface)
            }
            .background(Color.surface.ignoresSafeArea())
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
            .font(.scoutTitle)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: .radiusBlock, style: .continuous))
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
            .fillAccent
        case .secondary:
            .surfaceGrey
        }
    }
}

extension Color {
    static let errorAccent = fillDanger
}
