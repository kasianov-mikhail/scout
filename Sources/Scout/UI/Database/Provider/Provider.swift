//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
protocol Provider: ObservableObject {
    associatedtype Output

    var result: ProviderResult<Output>? { get set }

    func fetch(in database: AppDatabase) async throws -> Output
}

typealias ProviderResult<T> = Result<T, Error>

extension Provider {
    func fetchAgain(in database: AppDatabase) async {
        result = nil
        result = await resolve(in: database)
    }

    func fetchIfNeeded(in database: AppDatabase) async {
        guard result == nil else { return }
        result = await resolve(in: database)
    }
}

extension Provider {
    private func resolve(in database: AppDatabase) async -> ProviderResult<Output> {
        do {
            return .success(try await fetch(in: database))
        } catch {
            return .failure(error)
        }
    }
}
