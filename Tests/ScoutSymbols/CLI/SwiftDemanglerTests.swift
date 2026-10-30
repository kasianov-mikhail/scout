//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Testing

@testable import ScoutSymbolsCore

@Suite("SwiftDemangler")
struct SwiftDemanglerTests {
    @Test("Non-Swift names return no mapping without running the demangler")
    func ignoresForeignNames() throws {
        let demangler = SwiftDemangler { _ in
            Issue.record("The demangler must not run")
            return ""
        }

        #expect(try demangler.names(mangled: ["main", "_ZN3foo"]) == [:])
    }

    #if os(macOS)
        @Test("Unique Swift names are demangled and mapped back to their originals")
        func mapsUniqueSwiftNames() throws {
            let demangler = SwiftDemangler { input in
                input.split(separator: "\n")
                    .map { "Readable(\($0))" }
                    .joined(separator: "\n")
            }

            let names = try demangler.names(mangled: ["$sA", "_$sB", "$sA", "main"])

            #expect(names == ["$sA": "Readable($sA)", "_$sB": "Readable(_$sB)"])
        }

        @Test("Every supported Swift prefix is recognized", arguments: ["$sA", "_$sA", "$SA", "_$SA", "_T0A"])
        func recognizesSwiftPrefix(name: String) throws {
            let demangler = SwiftDemangler { _ in "Readable" }

            #expect(try demangler.names(mangled: [name]) == [name: "Readable"])
        }

        @Test("A demangler failure is propagated")
        func propagatesFailure() {
            let demangler = SwiftDemangler { _ in throw DemanglerError(status: 1) }

            #expect(throws: DemanglerError.self) {
                try demangler.names(mangled: ["$sA"])
            }
        }
    #else
        @Test("Non-macOS platforms leave Swift names without a mapping")
        func unsupportedPlatform() throws {
            let demangler = SwiftDemangler { _ in
                Issue.record("The demangler must not run")
                return ""
            }

            #expect(try demangler.names(mangled: ["$sA"]) == [:])
        }
    #endif
}
