//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

typealias RefreshAction = @MainActor () async -> Bool

extension View {
    func autoRefresh(_ refresh: @escaping RefreshAction) -> some View {
        modifier(AutoRefreshModifier(token: 0, refreshers: [refresh]))
    }

    func autoRefresh(on token: some Equatable, _ refresh: @escaping RefreshAction) -> some View {
        modifier(AutoRefreshModifier(token: token, refreshers: [refresh]))
    }

    func autoRefresh(rotating refreshers: [RefreshAction]) -> some View {
        modifier(AutoRefreshModifier(token: 0, refreshers: refreshers))
    }
}
