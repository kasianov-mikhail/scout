//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import HostedConnector
@testable import Scout

/// Verifies that `HTTPDatabase` percent-encodes query parameters so reserved
/// delimiters survive the trip to the server.
@Suite("Hosted query encoding")
struct HostedQueryEncodingTests {
    private let database = HTTPDatabase(url: URL(string: "https://example.com/")!, apiKey: nil)
    private let day = Date(timeIntervalSince1970: 1_750_000_000).startOfDay

    @Test("The series name and category parameters are percent-encoded")
    func seriesParametersAreEncoded() throws {
        let url = try #require(
            database.seriesEndpoint(
                for: SeriesQuery(
                    name: "Save & Exit",
                    category: "a=b/c?d+e",
                    range: day..<day.addingDay()
                )
            )
        )
        let items = queryItems(of: url)

        #expect(items["name"] == "Save & Exit")
        #expect(items["category"] == "a=b/c?d+e")

        // URLComponents decodes reserved delimiters but reads a literal `+` as
        // itself, so assert on the raw encoding to guard against a server that
        // form-decodes `+` into a space.
        #expect(try rawQuery(of: url).contains("%2B"))
    }

    @Test(
        "The values parameter emits the raw wire strings int and double",
        arguments: [
            (SeriesQuery.Values.int, "int"),
            (SeriesQuery.Values.double, "double"),
        ])
    func valuesEmitsWireString(_ values: SeriesQuery.Values, _ expected: String) throws {
        let url = try #require(
            database.seriesEndpoint(for: SeriesQuery(values: values, range: day..<day.addingDay()))
        )

        #expect(values.rawValue == expected)
        #expect(SeriesQuery.Values(rawValue: expected) == values)
        #expect(queryItems(of: url)["values"] == expected)
    }

    @Test("An explicit source is carried as a query parameter")
    func seriesSourceIsEncoded() throws {
        let url = try #require(
            database.seriesEndpoint(
                for: SeriesQuery(name: "Session", source: .event, range: day..<day.addingDay())
            )
        )

        #expect(queryItems(of: url)["source"] == "event")
        #expect(queryItems(of: url)["name"] == "Session")
    }

    @Test("An absent source omits the parameter")
    func seriesSourceOmittedWhenNil() throws {
        let url = try #require(
            database.seriesEndpoint(for: SeriesQuery(name: "Session", range: day..<day.addingDay()))
        )

        #expect(queryItems(of: url)["source"] == nil)
    }

    @Test("A last reduce is carried as a query parameter")
    func seriesReduceIsEncoded() throws {
        let url = try #require(
            database.seriesEndpoint(
                for: SeriesQuery(category: "meter", reduce: .last, range: day..<day.addingDay())
            )
        )

        #expect(queryItems(of: url)["reduce"] == "last")
    }

    @Test("A sum reduce omits the parameter")
    func seriesReduceOmittedWhenSum() throws {
        let url = try #require(
            database.seriesEndpoint(for: SeriesQuery(category: "counter", range: day..<day.addingDay()))
        )

        #expect(queryItems(of: url)["reduce"] == nil)
    }

    @Test("The lookup field list is percent-encoded")
    func lookupFieldsAreEncoded() throws {
        let url = try #require(database.recordEndpoint(recordName: "abc", fields: ["a b", "c+d"]))

        #expect(queryItems(of: url)["fields"] == "a b,c+d")
        #expect(try rawQuery(of: url).contains("c%2Bd"))
    }

    private func queryItems(of url: URL) -> [String: String] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        return (components?.queryItems ?? []).reduce(into: [:]) { $0[$1.name] = $1.value }
    }

    private func rawQuery(of url: URL) throws -> String {
        try #require(URLComponents(url: url, resolvingAgainstBaseURL: true)?.percentEncodedQuery)
    }
}
