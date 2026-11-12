//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// The main action of a screen: accent fill, white label, 50 pt high.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.scoutTitle)
            .foregroundStyle(Color.textOnFill)
            .frame(maxWidth: .infinity)
            .frame(height: .buttonHeight)
            .background(Color.fillAccent, in: RoundedRectangle(cornerRadius: .radiusBlock))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// The second action of a screen: grey fill, primary label.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.scoutTitle)
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: .buttonHeight)
            .background(Color.surfaceGrey, in: RoundedRectangle(cornerRadius: .radiusBlock))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// An outline action: hairline border, primary label.
struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.scoutTitle)
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: .buttonHeight)
            .overlay {
                RoundedRectangle(cornerRadius: .radiusBlock)
                    .stroke(Color.lineSeparator, lineWidth: .hairline)
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var prominent: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == OutlineButtonStyle {
    static var outline: OutlineButtonStyle { OutlineButtonStyle() }
}
