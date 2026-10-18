//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation
import SymbolTable
import Testing

@testable import Scout
@testable import Support

@Suite("BundledSymbols")
struct BundledSymbolsTests {
    let uuid = UUID(uuidString: "C8ED9CB2-606E-301A-A5F8-CAA01E39224F")!

    @Test("A table for the running executable becomes an index and a file record")
    func matchingTable() throws {
        let symbols = try #require(BundledSymbols(bundle: try makeBundle(), executable: uuid))

        #expect(symbols.index.recordType == "Symbols")
        #expect(symbols.index.recordID == uuid.uuidString)
        #expect(symbols.file.recordType == "SymbolsFile")
        #expect(symbols.file.recordID == UUID(symbolsFile: uuid).uuidString)
        #expect(symbols.file["image_uuid"] == uuid.uuidString)
        #expect(symbols.file["file"] == symbols.data)
    }

    @Test("A table from another build is ignored")
    func otherBuild() throws {
        #expect(BundledSymbols(bundle: try makeBundle(), executable: UUID()) == nil)
    }

    @Test("A bundle without a table has no symbols")
    func missingTable() {
        let bundle = Bundle(url: FileManager.default.temporaryDirectory)!

        #expect(BundledSymbols(bundle: bundle, executable: uuid) == nil)
    }

    @Test("A backend without the index gets the file and then the index")
    func upload() async throws {
        let database = InMemoryDatabase()
        let backend = Backend(id: "b-1", database: database, displayName: "b-1", engine: .cloudKit)
        let symbols = try #require(BundledSymbols(bundle: try makeBundle(), executable: uuid))

        await backend.upload(symbols: symbols, defaults: try makeDefaults())

        #expect(database.records.map(\.recordType) == ["SymbolsFile", "Symbols"])
    }

    @Test("A backend that already has the index gets nothing")
    func existingIndex() async throws {
        let database = InMemoryDatabase()
        let backend = Backend(id: "b-1", database: database, displayName: "b-1", engine: .cloudKit)
        let symbols = try #require(BundledSymbols(bundle: try makeBundle(), executable: uuid))
        database.records = [symbols.index]

        await backend.upload(symbols: symbols, defaults: try makeDefaults())

        #expect(database.writeCount == 0)
    }

    @Test("A finished upload is not checked again")
    func repeatedUpload() async throws {
        let database = InMemoryDatabase()
        let backend = Backend(id: "b-1", database: database, displayName: "b-1", engine: .cloudKit)
        let symbols = try #require(BundledSymbols(bundle: try makeBundle(), executable: uuid))
        let defaults = try makeDefaults()

        await backend.upload(symbols: symbols, defaults: defaults)
        database.records = []
        await backend.upload(symbols: symbols, defaults: defaults)

        #expect(database.writeCount == 2)
        #expect(database.records.isEmpty)
    }

    private func makeBundle() throws -> Bundle {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let table = SymbolTable(uuid: uuid, functions: [], lines: [], inlines: [])
        try table.data.write(to: directory.appendingPathComponent("scout.scoutsym"))
        return try #require(Bundle(url: directory))
    }

    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: UUID().uuidString))
    }
}
