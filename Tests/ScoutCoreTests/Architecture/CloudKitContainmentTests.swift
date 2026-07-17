//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

/// Enforces the layer boundary the hexagonal refactor established: CloudKit is
/// an adapter, not a dependency of the rest of the package.
///
/// Only files under `Sources/ScoutNative/` may `import CloudKit`; `ScoutCore`,
/// `ScoutHosted`, and `ScoutUI` speak the neutral `Record`/`RecordQuery`
/// vocabulary instead.
///
@Suite("CloudKit containment")
struct CloudKitContainmentTests {
    @Test("CloudKit is imported only inside the Native adapter")
    func cloudKitConfinedToAdapter() throws {
        let sources = try Self.sourcesDirectory()
        let adapter = sources.appendingPathComponent("ScoutNative")

        let offenders = try Self.swiftFiles(in: sources)
            .filter { !$0.path.hasPrefix(adapter.path + "/") }
            .filter { (try? Self.importsCloudKit($0)) == true }
            .map(\.lastPathComponent)
            .sorted()

        #expect(offenders.isEmpty, "import CloudKit found outside the CloudKit adapter: \(offenders)")
    }

    /// Walks up from this test file to the package root and returns its
    /// `Sources` directory.
    ///
    private static func sourcesDirectory() throws -> URL {
        var directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while directory.path != "/" {
            if FileManager.default.fileExists(atPath: directory.appendingPathComponent("Package.swift").path) {
                return directory.appendingPathComponent("Sources")
            }
            directory.deleteLastPathComponent()
        }
        throw ContainmentError.packageRootNotFound
    }

    private static func swiftFiles(in directory: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            throw ContainmentError.notEnumerable(directory.path)
        }
        return enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    private static func importsCloudKit(_ file: URL) throws -> Bool {
        try String(contentsOf: file, encoding: .utf8)
            .split(separator: "\n")
            .contains { $0.trimmingCharacters(in: .whitespaces) == "import CloudKit" }
    }

    private enum ContainmentError: Error {
        case packageRootNotFound
        case notEnumerable(String)
    }
}
