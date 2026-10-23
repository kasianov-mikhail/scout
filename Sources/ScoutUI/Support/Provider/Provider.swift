//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

typealias ProviderResult<T> = Result<T, Error>

@MainActor
protocol Provider: ObservableObject, Refreshable {
    associatedtype Output

    var result: ProviderResult<Output>? { get set }

    func fetch(in database: DatabaseReader) async throws -> Output
}

extension Provider {
    var isLoading: Bool {
        result == nil
    }

    func fetchAgain(in database: DatabaseReader) async {
        if ProcessInfo.processInfo.isPreview {
            return
        }
        do {
            result = .success(try await fetch(in: database))
        } catch is CancellationError {
            return
        } catch {
            result = .failure(error)
        }
    }

    func fetchIfNeeded(in database: DatabaseReader) async {
        guard result == nil else {
            return
        }
        await fetchAgain(in: database)
    }

    func fetchIfFailed(in database: DatabaseReader) async {
        guard error != nil else {
            return
        }
        await fetchAgain(in: database)
    }

    func fetchLatest(in database: DatabaseReader) async {
        if ProcessInfo.processInfo.isPreview {
            return
        }
        do {
            result = .success(try await fetch(in: database))
        } catch is CancellationError {
            return
        } catch {
            if result == nil {
                result = .failure(error)
            }
        }
    }
}

protocol SeriesProvider: Provider {
    func fetch(in database: SeriesReader) async throws -> Output
}

extension SeriesProvider {
    func fetch(in database: DatabaseReader) async throws -> Output {
        try await fetch(in: database as SeriesReader)
    }
}

protocol AudienceProvider: Provider {
    func fetch(in database: AudienceReader) async throws -> Output
}

extension AudienceProvider {
    func fetch(in database: DatabaseReader) async throws -> Output {
        try await fetch(in: database as AudienceReader)
    }
}

protocol DeviceProvider: Provider {
    func fetch(in database: DeviceReader) async throws -> Output
}

extension DeviceProvider {
    func fetch(in database: DatabaseReader) async throws -> Output {
        try await fetch(in: database as DeviceReader)
    }
}

protocol RecordProvider: Provider {
    func fetch(in database: RecordReader) async throws -> Output
}

extension RecordProvider {
    func fetch(in database: DatabaseReader) async throws -> Output {
        try await fetch(in: database as RecordReader)
    }
}
