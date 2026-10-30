//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation

package struct UsageError: Error {
    package let message: String

    package init(message: String) {
        self.message = message
    }
}

package enum Command {
    case convert(input: URL, output: URL)
    case lookup(table: URL, offsets: [UInt64])

    package init(arguments: [String]) throws {
        var remaining = arguments[...]
        switch remaining.popFirst() {
        case "convert":
            self = try Self.convert(arguments: remaining)
        case "lookup":
            self = try Self.lookup(arguments: remaining)
        default:
            throw UsageError(message: "Expected the convert or lookup command.")
        }
    }

    private static func convert(arguments: ArraySlice<String>) throws -> Command {
        var remaining = arguments
        var input: URL?
        var output = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        while let argument = remaining.popFirst() {
            if argument == "--output" {
                guard let path = remaining.popFirst() else {
                    throw UsageError(message: "--output needs a directory.")
                }
                output = URL(fileURLWithPath: path)
            } else if input == nil {
                input = URL(fileURLWithPath: argument)
            } else {
                throw UsageError(message: "Unexpected argument \(argument).")
            }
        }

        guard let input else {
            throw UsageError(message: "Expected a .dSYM or DWARF file.")
        }
        return .convert(input: input, output: output)
    }

    private static func lookup(arguments: ArraySlice<String>) throws -> Command {
        guard let path = arguments.first, arguments.count > 1 else {
            throw UsageError(message: "Expected a .scoutsym file and at least one offset.")
        }
        let offsets = try arguments.dropFirst().map { argument in
            guard let offset = UInt64(argument.replacingOccurrences(of: "0x", with: ""), radix: 16) else {
                throw UsageError(message: "\(argument) is not a hexadecimal offset.")
            }
            return offset
        }
        return .lookup(table: URL(fileURLWithPath: path), offsets: offsets)
    }
}

extension URL {
    package var dwarfFiles: [URL] {
        get throws {
            guard pathExtension == "dSYM" else {
                return [self]
            }
            let directory = appendingPathComponent("Contents/Resources/DWARF")
            return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        }
    }
}
