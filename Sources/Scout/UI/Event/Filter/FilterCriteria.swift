//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

class FilterCriteria<T: Hashable & CaseIterable>: ObservableObject {
    var selected: Binding<Set<T>>

    @Published private var cache: Set<T>
    @Published private var isApplied = false

    init(selected: Binding<Set<T>>) {
        self.selected = selected
        self.cache = selected.wrappedValue
    }

    deinit {
        if isApplied {
            selected.wrappedValue = cache
        }
    }
}

extension FilterCriteria {
    func isSelected(_ item: T) -> Bool {
        cache.contains(item)
    }

    func toggle(_ item: T) {
        cache.toggle(item)
    }
}

extension FilterCriteria {
    var isApplyEnabled: Bool {
        !cache.isEmpty && cache != selected.wrappedValue
    }

    func apply() {
        isApplied = true
    }
}

extension FilterCriteria {
    var isResetEnabled: Bool {
        cache != Set(T.allCases)
    }

    func reset() {
        cache = Set(T.allCases)
    }
}

extension Set {
    fileprivate mutating func toggle(_ element: Element) {
        if !contains(element) {
            insert(element)
        } else {
            remove(element)
        }
    }
}
