//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import SymbolTable

@MainActor
final class BacktraceProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<BacktraceDetail?>?

    private let incidentID: String

    init(_ result: ProviderResult<Output>? = nil, incidentID: String) {
        self.incidentID = incidentID
        self.result = result
    }

    func fetch(in database: RecordReader) async throws -> BacktraceDetail? {
        guard let id = UUID(uuidString: incidentID) else {
            return nil
        }
        do {
            let record = try await database.lookup(
                recordName: UUID(incidentBacktrace: id).uuidString,
                fields: ["backtrace"]
            )

            guard let data: Data = record["backtrace"] else {
                return nil
            }
            let backtrace = try JSONDecoder().decode(Backtrace.self, from: data)
            let tables = try await SymbolTableCache.shared.tables(uuids: backtrace.images.compactMap(\.uuid), database: database)
            return BacktraceDetail(backtrace: backtrace, tables: tables)
        } catch is RecordNotFoundError {
            return nil
        }
    }
}

extension BacktraceProvider {
    var detail: BacktraceDetail? {
        guard case .success(let detail) = result else {
            return nil
        }
        return detail
    }
}

struct BacktraceDetail: Equatable {
    let backtrace: Backtrace
    let tables: [UUID: SymbolTable]

    static var sample: BacktraceDetail {
        BacktraceDetail(backtrace: .sample, tables: [:])
    }
}
