//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

typealias ProviderResult<T> = Result<T, Error>

@MainActor
protocol Provider: ObservableObject {
    associatedtype Output

    var result: ProviderResult<Output>? { get set }

    func fetch(in database: DatabaseReader) async throws -> Output
}
