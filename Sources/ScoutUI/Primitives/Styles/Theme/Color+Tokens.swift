//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

/// The Scout design-system colors.
///
/// The light values are the design's own. The dark values are not in the design:
/// they keep the closest system color so dark mode stays readable.
extension Color {
    // MARK: - Text

    static let textPrimary = designColor(light: 0x000000, dark: 0xFFFFFF)
    static let textSecondary = designColor(light: 0x6C6C70, dark: 0x98989F)
    static let textMuted = designColor(light: 0x8E8E93, dark: 0x8E8E93)
    static let textDisabled = designColor(light: 0xC7C7CC, dark: 0x48484A)
    static let textLink = designColor(light: 0x007AFF, dark: 0x0A84FF)
    static let textDanger = designColor(light: 0xC4001A, dark: 0xFF453A)
    static let textWarning = designColor(light: 0xB35C00, dark: 0xFF9F0A)
    static let textCaution = designColor(light: 0x8A6D00, dark: 0xFFD60A)
    static let textSuccess = designColor(light: 0x1E7D34, dark: 0x30D158)
    static let textResource = designColor(light: 0x3634A3, dark: 0x5E5CE6)
    static let textSession = designColor(light: 0x12A594, dark: 0x40C8E0)
    static let textOnFill = designColor(light: 0xFFFFFF, dark: 0xFFFFFF)

    // MARK: - Surface

    static let surface = designColor(light: 0xFFFFFF, dark: 0x000000)
    static let surfaceGrey = designColor(light: 0xF2F2F7, dark: 0x1C1C1E)
    static let surfaceSkeleton = designColor(light: 0xE5E5EA, dark: 0x2C2C2E)
    static let surfaceBarIdle = designColor(light: 0xD1D1D6, dark: 0x3A3A3C)
    static let surfaceSelected = designColor(light: 0x007AFF, dark: 0x0A84FF, lightAlpha: 0.12, darkAlpha: 0.2)
    static let surfaceTrack = designColor(light: 0xE8F1FE, dark: 0x0A2A4A)

    // MARK: - Fill

    static let fillAccent = designColor(light: 0x007AFF, dark: 0x0A84FF)
    static let fillDanger = designColor(light: 0xFF3B30, dark: 0xFF453A)
    static let fillDangerStrong = designColor(light: 0xC4001A, dark: 0xB3261E)
    static let fillWarning = designColor(light: 0xFF9500, dark: 0xFF9F0A)
    static let fillCaution = designColor(light: 0xFFCC00, dark: 0xFFD60A)
    static let fillSuccess = designColor(light: 0x34C759, dark: 0x30D158)
    static let fillResource = designColor(light: 0x5856D6, dark: 0x5E5CE6)
    static let fillSession = designColor(light: 0x12A594, dark: 0x40C8E0)
    static let fillDevice = designColor(light: 0x32ADE6, dark: 0x64D2FF)
    static let fillLevel = designColor(light: 0x8E8E93, dark: 0x8E8E93)

    // MARK: - Tint

    static let tintDanger = designColor(light: 0xFDEEEE, dark: 0xFF453A, darkAlpha: 0.16)
    static let tintWarning = designColor(light: 0xFFF4E5, dark: 0xFF9F0A, darkAlpha: 0.16)
    static let tintCaution = designColor(light: 0xFDF7DE, dark: 0xFFD60A, darkAlpha: 0.16)
    static let tintSuccess = designColor(light: 0xE3F5E8, dark: 0x30D158, darkAlpha: 0.16)
    static let tintResource = designColor(light: 0xEFEFFC, dark: 0x5E5CE6, darkAlpha: 0.16)

    // MARK: - Line

    static let lineSeparator = designColor(light: 0xC6C6C8, dark: 0x38383A)
    static let lineSubtle = designColor(light: 0xD1D1D6, dark: 0x2C2C2E)
    static let lineTintDanger = designColor(light: 0xEED5D5, dark: 0xFF453A, darkAlpha: 0.24)
    static let lineTintWarning = designColor(light: 0xF2DFC4, dark: 0xFF9F0A, darkAlpha: 0.24)
    static let lineTintCaution = designColor(light: 0xE6E1CC, dark: 0xFFD60A, darkAlpha: 0.24)
    static let lineTintResource = designColor(light: 0xDADAF2, dark: 0x5E5CE6, darkAlpha: 0.24)

    // MARK: - Code

    static let codeSurface = designColor(light: 0xF6F8FA, dark: 0x161B22)
    static let codeText = designColor(light: 0x1F2328, dark: 0xE6EDF3)
    static let codeKey = designColor(light: 0x0550AE, dark: 0x79C0FF)
    static let codeString = designColor(light: 0x0A3069, dark: 0xA5D6FF)
}
