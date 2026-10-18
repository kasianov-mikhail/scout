//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

private let swiftPrefixes = ["$s", "_$s", "$S", "_$S", "_T0"]

struct DemanglerError: Error {
    let status: Int32
}

struct SwiftDemangler {
    func names(mangled: [String]) throws -> [String: String] {
        let unique = Array(Set(mangled.filter { name in swiftPrefixes.contains { name.hasPrefix($0) } }))
        guard !unique.isEmpty else {
            return [:]
        }
        #if os(macOS)
            let demangled = try run(input: unique.joined(separator: "\n"))
            return Dictionary(zip(unique, demangled.split(separator: "\n").map(String.init)), uniquingKeysWith: { first, _ in first })
        #else
            return [:]
        #endif
    }

    #if os(macOS)
        private func run(input: String) throws -> String {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
            process.arguments = ["swift-demangle", "--simplified"]
            let inputPipe = Pipe()
            let outputPipe = Pipe()
            process.standardInput = inputPipe
            process.standardOutput = outputPipe
            try process.run()

            let writer = Thread {
                inputPipe.fileHandleForWriting.write(Data(input.utf8))
                try? inputPipe.fileHandleForWriting.close()
            }
            writer.start()
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                throw DemanglerError(status: process.terminationStatus)
            }
            return String(decoding: data, as: UTF8.self)
        }
    #endif
}
