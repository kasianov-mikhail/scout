//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// The persistent container for the application.
///
/// This container is created using the `newContainer(named:)` function, which attempts to locate
/// the Core Data model file in the module's bundle and initializes a new `NSPersistentContainer` with it.
///
/// - Note: The persistent container is a singleton instance that is lazily initialized.
///
let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer.newContainer(named: "Scout")

    container.loadPersistentStores { _, error in
        if let error {
            print("Error loading Core Data store: \(error.localizedDescription)")
        }
    }
    return container
}()

extension NSPersistentContainer {

    /// Creates a new `NSPersistentContainer` with the specified name.
    ///
    /// This function attempts to locate the Core Data model file with the given name
    /// in the module's bundle. If the model file is found, it creates an `NSManagedObjectModel`
    /// from the file and uses it to initialize a new `NSPersistentContainer`.
    ///
    /// - Parameter name: The name of the Core Data model file (without the extension).
    /// - Returns: A new `NSPersistentContainer` initialized with the specified model.
    /// - Throws: A runtime error if the model file cannot be found or if the model cannot be created.
    ///
    /// Example usage:
    /// ```
    /// let container = NSPersistentContainer.newContainer(named: "Scout")
    /// ```
    ///
    static func newContainer(named name: String) -> NSPersistentContainer {
        guard let modelURL = Bundle.module.url(forResource: name, withExtension: "momd") else {
            fatalError("Failed to find data model")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        return NSPersistentContainer(name: name, managedObjectModel: model)
    }
}
