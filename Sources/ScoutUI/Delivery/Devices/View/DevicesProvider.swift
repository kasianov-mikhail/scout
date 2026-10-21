//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class DevicesProvider: ObservableObject, DeviceProvider {
    @Published var result: ProviderResult<[DeviceSummary]>?

    init(_ result: ProviderResult<Output>? = nil) {
        self.result = result
    }

    func fetch(in database: DeviceReader) async throws -> [DeviceSummary] {
        try await database.devices(in: Date().trailingYear).compactMap(DeviceSummary.init(activity:))
    }
}
