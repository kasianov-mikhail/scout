//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(UIKit)
import SnapshotTesting
import SwiftUI

@testable import Scout

enum ViewSnapshot {
    // Baselines are recorded on iOS 26, so other CI legs skip the snapshot suites
    // instead of diffing against images rendered by a different OS. #available
    // checks the simulated iOS runtime; ProcessInfo reports the host macOS
    // version under the simulator and misgates.
    static let isSupported: Bool = {
        guard #available(iOS 26, *) else { return false }
        if #available(iOS 27, *) { return false }
        return true
    }()
}

extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    static func scout(width: CGFloat = 393, height: CGFloat) -> Snapshotting {
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(displayScale: 2),
        ])
        return .image(perceptualPrecision: 0.98, layout: .fixed(width: width, height: height), traits: traits)
    }
}
#endif
