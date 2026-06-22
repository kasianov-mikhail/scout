//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@Suite("MatrixUploader")
struct MatrixUploaderTests {
    let database = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()
    let uploader: MatrixUploader<GridCell<Int>>

    init() {
        uploader = MatrixUploader(
            database: database,
            maxRetry: 3,
            matrix: Matrix(
                recordType: Int.recordType,
                date: now,
                name: "matrix",
                cells: []
            )
        )
    }

    @Test("Successful upload calls save on the database")
    func testUploadSuccess() async throws {
        try await uploader.upload()

        #expect(database.records.filter { $0.recordType == Int.recordType }.count == 1)
    }

    @Test("Upload retries and merges on serverRecordChanged error")
    func testUploadServerRecordChangedMerges() async throws {
        database.writeErrors.append(createMergeError())

        try await uploader.upload()

        #expect(database.records.filter { $0.recordType == Int.recordType }.count == 1)
    }

    @Test("Upload falls back to newMatrix after max retries")
    func testUploadMaxRetryFallback() async throws {
        for _ in 0..<(uploader.maxRetry + 1) {
            database.writeErrors.append(createMergeError())
        }
        try await uploader.upload()

        #expect(database.records.filter { $0.recordType == Int.recordType }.count == 1)
    }
}

private let now = Date()

private func createMergeError() -> RecordConflictError {
    RecordConflictError(serverRecord: Record.matrixStub(date: now))
}
