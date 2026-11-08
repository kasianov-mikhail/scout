//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class ModelDetailProvider: ObservableObject, Provider {
    typealias Output = ModelDetail

    @Published var result: ProviderResult<ModelDetail>?
    @Published var range: IncidentRange

    let model: String?

    private var loadedRange: IncidentRange?

    var modelName: String {
        model.map { DeviceModel(identifier: $0).name } ?? "Unknown"
    }

    init(_ result: ProviderResult<ModelDetail>? = nil, model: String?, range: IncidentRange = .week, activities: [DeviceActivity]? = nil) {
        self.model = model
        self.range = range
        self.result = result ?? activities.map { ProviderResult<ModelDetail>.success(ModelDetail(model: model, activities: $0)) }
        self.loadedRange = result == nil && activities == nil ? nil : range
    }

    func load(in database: DatabaseReader) async {
        guard loadedRange != range else {
            return
        }
        let requested = range
        await fetchAgain(in: database)
        guard !Task.isCancelled, range == requested else {
            return
        }
        if case .success = result {
            loadedRange = requested
        }
    }

    func fetch(in database: DatabaseReader) async throws -> ModelDetail {
        let activities = try await database.devices(in: range.range(now: Date()))
        return ModelDetail(model: model, activities: activities)
    }
}
