//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A class that provides parameters by fetching them from a CloudKit record.
@MainActor class ParamProvider: ObservableObject {

    /// The ID of the CloudKit record from which parameters are fetched.
    let recordID: CKRecord.ID

    /// An array of items fetched from the CloudKit record.
    @Published var items: [Item]?

    /// Initializes a new instance of `ParamProvider` with the specified record ID.
    init(recordID: CKRecord.ID) {
        self.recordID = recordID
    }

    /// Fetches the parameters from the CloudKit record if they have not been fetched yet.
    ///
    /// - Parameter container: The CloudKit container to use for fetching the record.
    ///
    func fetchIfNeeded(in database: DatabaseController) async {
        if items == nil {
            await fetch(in: database)
        }
    }
}

extension ParamProvider {

    /// A struct representing a parameters with a key-value pair.
    struct Item: Identifiable, Comparable, Hashable, CustomStringConvertible {
        static func < (lhs: Item, rhs: Item) -> Bool {
            lhs.key < rhs.key
        }

        let id = UUID()
        let key: String
        let value: String

        /// Converts the fetched data into an array of `Item` objects.
        ///
        /// - Parameter data: The data to convert.
        /// - Returns: An array of `Item` objects.
        /// - Throws: An error if the data cannot be decoded.
        ///
        fileprivate static func fromData(_ data: Data) throws -> [Item] {
            try JSONDecoder().decode([String: String].self, from: data).map(Item.init)
        }

        var description: String {
            "\(key): \(value)"
        }
    }
}

// MARK: - Private Methods

extension ParamProvider {

    /// Fetches the parameters from the CloudKit record.
    ///
    /// - Parameter container: The CloudKit container to use for fetching the record.
    ///
    fileprivate func fetch(in database: DatabaseController) async {
        do {
            items = try await database
                .record(for: recordID)["params"]
                .map(Item.fromData)?
                .sorted()
        } catch {
            print(error.localizedDescription)
            items = nil
        }
    }
}
