//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct SchemaError: LocalizedError {
    let recordTypes: [String]

    var errorDescription: String? {
        let list = recordTypes.joined(separator: ", ")
        return "CloudKit schema is outdated. Missing record types: \(list). Run upload-schema.sh to fix."
    }
}

private let schemaRecordTypes = [
    "Event", "Session", "Crash",
    "DateIntMatrix", "DateDoubleMatrix", "PeriodMatrix",
]

extension CKContainer {

    /// Queries each record type to verify the CloudKit schema is up to date.
    /// Throws a `SchemaError` if any record types have schema issues.
    ///
    func verifySchema() async throws {
        guard let status = try? await accountStatus(), status == .available else {
            return
        }

        var invalid: [String] = []

        for recordType in schemaRecordTypes {
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

            do {
                _ = try await publicCloudDatabase.records(matching: query, resultsLimit: 1)
            } catch let error as CKError where error.isSchemaError {
                print("[Scout] Schema error for '\(recordType)': \(error.localizedDescription)")
                invalid.append(recordType)
            }
        }

        if !invalid.isEmpty {
            let containerID = containerIdentifier ?? "<container-id>"

            print("[Scout] Upload the schema to your CloudKit container using: ./upload-schema.sh <team-id> \(containerID)")
            print("[Scout] For details, see INSTALLATION.md")

            throw SchemaError(recordTypes: invalid)
        }
    }
}
