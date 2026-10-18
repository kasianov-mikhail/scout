//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import DWARF
import Foundation
import SymbolTable

private let usage = """
    Usage:
      scout-symbols convert <path to .dSYM or DWARF file> [--output <directory or file.scoutsym>]
          Writes <image UUID>.scoutsym for every arm64 image, or one image to the given file.
      scout-symbols lookup <path to .scoutsym> <hex offset>...
          Prints the frames at each offset, innermost first.
    """

@main
struct ScoutSymbols {
    static func main() {
        do {
            switch try Command(arguments: Array(CommandLine.arguments.dropFirst())) {
            case .convert(let input, let output):
                let files = try input.dwarfFiles
                guard output.pathExtension != "scoutsym" || files.count == 1 else {
                    throw UsageError(message: "The dSYM holds \(files.count) images; pass a directory to --output.")
                }
                for file in files {
                    print("Wrote \(try convert(file: file, output: output).path)")
                }
            case .lookup(let file, let offsets):
                let table = try SymbolTable(data: Data(contentsOf: file))
                for offset in offsets {
                    print(lookup(table: table, offset: offset))
                }
            }
        } catch let error as UsageError {
            FileHandle.standardError.write(Data("\(error.message)\n\n\(usage)\n".utf8))
            exit(2)
        } catch {
            FileHandle.standardError.write(Data("scout-symbols: \(error)\n".utf8))
            exit(1)
        }
    }

    private static func convert(file: URL, output: URL) throws -> URL {
        let table = try SymbolTable(image: MachOImage(data: Data(contentsOf: file)))
        let names = try SwiftDemangler().names(mangled: table.functions.map(\.name) + table.inlines.map(\.name))
        let readable = SymbolTable(
            uuid: table.uuid,
            functions: table.functions.map { SymbolTable.Function(start: $0.start, end: $0.end, name: names[$0.name] ?? $0.name) },
            lines: table.lines,
            inlines: table.inlines.map { SymbolTable.Inline(start: $0.start, end: $0.end, depth: $0.depth, name: names[$0.name] ?? $0.name, call: $0.call) }
        )

        let destination = output.pathExtension == "scoutsym" ? output : output.appendingPathComponent("\(table.uuid.uuidString).scoutsym")
        try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try readable.data.write(to: destination)
        return destination
    }

    private static func lookup(table: SymbolTable, offset: UInt64) -> String {
        let frames = table.frames(offset: offset).map { frame in
            "    \(frame.name) (\(frame.location.map { "\($0.file):\($0.line)" } ?? "?"))"
        }
        return (["0x\(String(offset, radix: 16))"] + frames).joined(separator: "\n")
    }
}
