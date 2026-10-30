//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutSymbols

@Suite("Command")
struct CommandTests {
    @Test("convert uses the current directory by default")
    func convertDefaultOutput() throws {
        let command = try Command(arguments: ["convert", "App.dSYM"])

        guard case .convert(let input, let output) = command else {
            Issue.record("Expected a convert command")
            return
        }
        #expect(input == URL(fileURLWithPath: "App.dSYM"))
        #expect(output == URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
    }

    @Test("convert accepts --output before the input")
    func convertExplicitOutput() throws {
        let command = try Command(arguments: ["convert", "--output", "Symbols", "App.dSYM"])

        guard case .convert(let input, let output) = command else {
            Issue.record("Expected a convert command")
            return
        }
        #expect(input == URL(fileURLWithPath: "App.dSYM"))
        #expect(output == URL(fileURLWithPath: "Symbols"))
    }

    @Test("lookup parses hexadecimal offsets with or without a prefix")
    func lookupOffsets() throws {
        let command = try Command(arguments: ["lookup", "App.scoutsym", "0", "0x10", "ABCDEF", "ffffffffffffffff"])

        guard case .lookup(let table, let offsets) = command else {
            Issue.record("Expected a lookup command")
            return
        }
        #expect(table == URL(fileURLWithPath: "App.scoutsym"))
        #expect(offsets == [0, 0x10, 0xABCDEF, UInt64.max])
    }

    @Test(
        "Invalid command lines are rejected",
        arguments: [
            [],
            ["unknown"],
            ["convert"],
            ["convert", "App.dSYM", "Extra"],
            ["convert", "App.dSYM", "--output"],
            ["lookup"],
            ["lookup", "App.scoutsym"],
            ["lookup", "App.scoutsym", "not-hex"],
        ])
    func invalidArguments(arguments: [String]) {
        #expect(throws: UsageError.self) {
            try Command(arguments: arguments)
        }
    }

    @Test("A non-dSYM path is already a DWARF file")
    func plainDWARFFile() throws {
        let url = URL(fileURLWithPath: "App.dwarf")

        #expect(try url.dwarfFiles == [url])
    }

    @Test("A dSYM expands to the files in its DWARF directory")
    func dSYMFiles() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let directory = root.appendingPathComponent("App.dSYM/Contents/Resources/DWARF")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let app = directory.appendingPathComponent("App")
        let framework = directory.appendingPathComponent("Framework")
        try Data().write(to: app)
        try Data().write(to: framework)

        let files = try root.appendingPathComponent("App.dSYM").dwarfFiles

        #expect(Set(files.map(\.lastPathComponent)) == ["App", "Framework"])
    }

    @Test("A dSYM without a DWARF directory reports a file-system error")
    func missingDWARFDirectory() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("dSYM")

        #expect(throws: (any Error).self) {
            try url.dwarfFiles
        }
    }
}
