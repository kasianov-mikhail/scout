//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct SchemaError: LocalizedError {
    let recordTypes: [String]

    var noun: String {
        recordTypes.count == 1 ? "record type" : "record types"
    }

    var errorDescription: String? {
        let list = recordTypes.joined(separator: ", ")
        return "CloudKit schema is outdated. Missing \(noun): \(list). Upload the Schema file via CloudKit Console."
    }
}

private let schemaRecordTypes = [
    EventObject.recordType,
    SessionObject.recordType,
    LaunchObject.recordType,
    VersionObject.recordType,
    InstallObject.recordType,
    DeviceObject.recordType,
    CrashObject.recordType,
    Int.recordType,
    Double.recordType,
    PeriodCell<Int>.recordType,
]

extension CKContainer {
    func schemaChecks() async -> [SchemaCheck] {
        await schemaChecks(for: schemaRecordTypes)
    }

    // Queries each record type; flaky non-schema failures are skipped so one
    // bad query doesn't abort the rest, and are absent from the result.
    func schemaChecks(for recordTypes: [String]) async -> [SchemaCheck] {
        guard let status = try? await accountStatus(), status == .available else { return [] }

        var checks: [SchemaCheck] = []

        for recordType in recordTypes {
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

            do {
                try await publicCloudDatabase.runner { database in
                    _ = try await database.records(matching: query, desiredKeys: [], resultsLimit: 1)
                }
                checks.append(SchemaCheck(recordType: recordType, isValid: true))
            } catch let error as CKError where error.isSchemaError {
                print("[Scout] Schema error for '\(recordType)': \(error.localizedDescription)")
                checks.append(SchemaCheck(recordType: recordType, isValid: false))
            } catch {
                print("[Scout] Skipping '\(recordType)': \(error.localizedDescription)")
                continue
            }
        }

        return checks
    }

    /// Queries each record type to verify the CloudKit schema is up to date.
    ///
    /// Throws a `SchemaError` if any record types have schema issues.
    ///
    func verifySchema() async throws {
        try await verifySchema(for: schemaRecordTypes)
    }

    func verifySchema(for recordTypes: [String]) async throws {
        let invalid = await schemaChecks(for: recordTypes).filter { !$0.isValid }.map(\.recordType)

        if invalid.count > 0 {
            let containerID = containerIdentifier ?? "<container-id>"

            print("[Scout] Upload the Schema file to '\(containerID)' via CloudKit Console: https://icloud.developer.apple.com/dashboard/")
            print("[Scout] For details, see docs/INSTALLATION.md")

            throw SchemaError(recordTypes: invalid)
        }
    }
}
