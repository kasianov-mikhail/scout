//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Logging
import Testing

@testable import Scout
@testable import Support

@MainActor
struct ScoutLogHandlerTests {
    @Test("Handler metadata reaches the stored params")
    func storesHandlerMetadata() throws {
        let runtime = makeQueuedRuntime()
        var logger = Logger(label: "test") { label in
            ScoutLogHandler(label: label, runtime: runtime)
        }
        logger[metadataKey: "user"] = "42"

        logger.info("Plain")
        logger.info("Tagged", metadata: ["screen": "home"])

        let events = try runtime.flushedContext().fetchAll(EventEntry.self)
        let plain = try #require(events.first { $0.name == "Plain" })
        let tagged = try #require(events.first { $0.name == "Tagged" })

        #expect(try makeParams(plain) == ["user": "42"])
        #expect(plain.paramCount == 1)
        #expect(try makeParams(tagged) == ["user": "42", "screen": "home"])
        #expect(tagged.paramCount == 2)
    }

    @Test("Call metadata wins over provider metadata, which wins over handler metadata")
    func mergesInSwiftLogOrder() throws {
        let runtime = makeQueuedRuntime()
        var handler = ScoutLogHandler(label: "test", runtime: runtime)
        handler.metadataProvider = Logger.MetadataProvider {
            ["source": "provider", "trace": "abc"]
        }
        var logger = Logger(label: "test") { _ in handler }
        logger[metadataKey: "source"] = "handler"
        logger[metadataKey: "user"] = "42"

        logger.info("Provided")
        logger.info("Explicit", metadata: ["source": "call"])

        let events = try runtime.flushedContext().fetchAll(EventEntry.self)
        let provided = try #require(events.first { $0.name == "Provided" })
        let explicit = try #require(events.first { $0.name == "Explicit" })

        #expect(try makeParams(provided) == ["source": "provider", "trace": "abc", "user": "42"])
        #expect(provided.paramCount == 3)
        #expect(try makeParams(explicit) == ["source": "call", "trace": "abc", "user": "42"])
        #expect(explicit.paramCount == 3)
    }

    @Test("An event without any metadata stores no params")
    func storesNoParamsWithoutMetadata() throws {
        let runtime = makeQueuedRuntime()
        let logger = Logger(label: "test") { label in
            ScoutLogHandler(label: label, runtime: runtime)
        }

        logger.info("Bare")

        let event = try #require(try runtime.flushedContext().fetchAll(EventEntry.self).first)
        #expect(event.params == nil)
        #expect(event.paramCount == 0)
    }
}

private func makeParams(_ event: EventEntry) throws -> [String: String] {
    let data = try #require(event.params)
    return try JSONDecoder().decode([String: String].self, from: data)
}
