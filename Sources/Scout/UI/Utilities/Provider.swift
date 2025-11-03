//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@MainActor
protocol Provider: AnyObject {
    associatedtype ResultType

    var result: ProviderResult<ResultType>? { get set }

    func fetch(in database: DatabaseController) async throws -> ResultType
}

typealias ProviderResult<T> = Result<T, Error>

extension Provider {
    func fetchAgain(in database: DatabaseController) async {
        result = nil
        result = await resolve(in: database)
    }

    func fetchIfNeeded(in database: DatabaseController) async {
        guard result == nil else { return }
        result = await resolve(in: database)
    }
}

extension Provider {
    private func resolve(in database: DatabaseController) async -> ProviderResult<ResultType> {
        do {
            return .success(try await fetch(in: database))
        } catch {
            return .failure(error)
        }
    }
}
