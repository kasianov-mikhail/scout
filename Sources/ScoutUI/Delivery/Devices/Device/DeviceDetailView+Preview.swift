//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#Preview("Device") {
    NavigationStack {
        DeviceDetailView(
            device: DeviceSummary.samples[0],
            provider: .init(.success(.sample), device: DeviceSummary.samples[0])
        )
    }
}

#Preview("Device loading") {
    NavigationStack {
        ScrollView {
            DeviceDetailView.Placeholder(range: .constant(.week))
        }
        .scrollIndicators(.hidden)
    }
}
