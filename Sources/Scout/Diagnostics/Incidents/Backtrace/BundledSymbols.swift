//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation
import SymbolTable

package struct BundledSymbols: Sendable {
    package static let indexType = "Symbols"
    package static let fileType = "SymbolsFile"

    static let main = BundledSymbols(bundle: .main, executable: LoadedImage.loaded().first?.uuid)

    let uuid: UUID
    let data: Data
    let appVersion: String?

    init?(bundle: Bundle, executable: UUID?) {
        guard let url = bundle.url(forResource: "scout", withExtension: "scoutsym") else {
            return nil
        }
        guard let data = FileManager.default.contents(atPath: url.path) else {
            return nil
        }
        guard let header = try? SymbolFileHeader(data: data), header.uuid == executable else {
            return nil
        }

        self.uuid = header.uuid
        self.data = data
        self.appVersion = bundle.marketingVersion
    }

    var index: Record {
        var record = Record(recordType: Self.indexType, recordID: uuid.uuidString)
        record["app_version"] = appVersion
        record["date"] = Date()
        return record
    }

    var file: Record {
        let id = UUID(symbolsFile: uuid)
        var record = Record(recordType: Self.fileType, recordID: id.uuidString)
        record["uuid"] = id.uuidString
        record["image_uuid"] = uuid.uuidString
        record["file"] = data
        record["date"] = Date()
        return record
    }
}

extension UUID {
    package init(symbolsFile: UUID) {
        self.init(digesting: [BundledSymbols.fileType, symbolsFile.uuidString])
    }
}
