//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A class that manages selection criteria for a set of items.
class Criteria<T: Hashable & CaseIterable>: ObservableObject {

    /// The currently selected items, bound to an external state.
    var selected: Binding<Set<T>>

    /// A cache of the selected items, used internally for managing state.
    @Published private var cache: Set<T>

    /// A flag indicating whether the criteria will be applied.
    @Published private var isApplied = false

    /// Initializes a new Criteria instance with the given selected items.
    /// - Parameter selected: A binding to the set of selected items.
    ///
    init(selected: Binding<Set<T>>) {
        self.selected = selected
        self.cache = selected.wrappedValue
    }

    /// If the criteria have been applied, updates the external state with the cached selection.
    deinit {
        if isApplied {
            selected.wrappedValue = cache
        }
    }
}

// MARK: - Criteria Actions

extension Criteria {

    /// Checks if a specific item is enabled (selected).
    func isSelected(_ item: T) -> Bool {
        cache.contains(item)
    }

    /// Toggles the selection state of a specific item.
    func toggle(_ item: T) {
        cache.toggle(item)
    }
}

extension Criteria {

    /// A computed property that indicates whether the apply action is enabled.
    var isApplyEnabled: Bool {
        !cache.isEmpty && cache != selected.wrappedValue
    }

    /// Marks the criteria as applied.
    func apply() {
        isApplied = true
    }
}

extension Criteria {

    /// A computed property that determines if the reset action is enabled.
    var isResetEnabled: Bool {
        cache != Set(T.allCases)
    }

    /// This method repopulates it with all the cases of the enum `T`,
    /// ensuring that the cache contains a complete set of these cases.
    /// 
    func reset() {
        cache = Set(T.allCases)
    }
}

// MARK: -

extension Set {

    /// Toggles the presence of the specified element in the collection.
    /// 
    /// If the element is already present, it will be removed. If the element is not present, it will be added.
    /// 
    /// - Parameter element: The element to be toggled in the collection.
    /// 
    fileprivate mutating func toggle(_ element: Element) {
        if !contains(element) {
            insert(element)
        } else {
            remove(element)
        }
    }
}
