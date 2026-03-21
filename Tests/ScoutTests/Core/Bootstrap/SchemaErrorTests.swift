//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import Scout

@Suite("CKError.isSchemaError")
struct SchemaErrorTests {
    // MARK: - Matching codes with schema messages

    @Test("invalidArguments with 'record type' message")
    func invalidArgumentsRecordType() {
        let error = makeCKError(code: .invalidArguments, message: "Invalid record type 'Foo'")
        #expect(error.isSchemaError)
    }

    @Test("invalidArguments with 'field' message")
    func invalidArgumentsField() {
        let error = makeCKError(code: .invalidArguments, message: "Unknown field 'bar'")
        #expect(error.isSchemaError)
    }

    @Test("serverRejectedRequest with 'not marked queryable' message")
    func serverRejectedQueryable() {
        let error = makeCKError(code: .serverRejectedRequest, message: "Field is not marked queryable")
        #expect(error.isSchemaError)
    }

    // MARK: - Matching codes without schema messages

    @Test("invalidArguments with unrelated message")
    func invalidArgumentsUnrelated() {
        let error = makeCKError(code: .invalidArguments, message: "Bad predicate format")
        #expect(!error.isSchemaError)
    }

    @Test("serverRejectedRequest with unrelated message")
    func serverRejectedUnrelated() {
        let error = makeCKError(code: .serverRejectedRequest, message: "Rate limit exceeded")
        #expect(!error.isSchemaError)
    }

    // MARK: - Non-matching codes

    @Test("networkFailure is not a schema error")
    func networkFailure() {
        let error = makeCKError(code: .networkFailure, message: "record type should not match")
        #expect(!error.isSchemaError)
    }

    @Test("networkUnavailable is not a schema error")
    func networkUnavailable() {
        let error = makeCKError(code: .networkUnavailable, message: "field should not match")
        #expect(!error.isSchemaError)
    }

    // MARK: - Case insensitivity

    @Test("message matching is case-insensitive")
    func caseInsensitive() {
        let error = makeCKError(code: .invalidArguments, message: "Unknown RECORD TYPE 'Foo'")
        #expect(error.isSchemaError)
    }

    // MARK: - Helper

    private func makeCKError(code: CKError.Code, message: String) -> CKError {
        let nsError = NSError(
            domain: CKErrorDomain,
            code: code.rawValue,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        return CKError(_nsError: nsError)
    }
}
