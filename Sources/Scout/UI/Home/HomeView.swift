//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

public struct HomeView: View {
    @StateObject private var dataSource: DataSourceModel
    @StateObject private var tint = Tint()

    /// Reads analytics from the active backend, defaulting to the first.
    ///
    /// When several backends are configured, a toolbar control lets the user
    /// switch between them; account and schema warnings only apply while the
    /// active backend asks for them (CloudKit does; Scout servers don't).
    ///
    public init(backends: [any Backend]) {
        _dataSource = StateObject(wrappedValue: DataSourceModel(backends: backends))
    }

    public var body: some View {
        NavigationStack {
            HomeContent()
                .id(dataSource.activeID)
                .navigationTitle(en: "Home")
                .backendWarnings(dataSource.activeBackend)
                .dismissable()
                .toolbar { dataSourceToolbar }
        }
        .task {
            if dataSource.hasChoice {
                await dataSource.refreshStatuses()
            }
        }
        .onboardingSheet()
        .tint(tint.value)
        .environmentObject(tint)
        .environment(\.database, dataSource.activeDatabase)
    }

    @ToolbarContentBuilder
    private var dataSourceToolbar: some ToolbarContent {
        if dataSource.hasChoice {
            ToolbarItem(placement: .topBarTrailing) {
                DataSourceMenu(servers: dataSource.servers, activeID: $dataSource.activeID)
            }
        }
    }
}

extension View {
    @ViewBuilder fileprivate func backendWarnings(_ backend: ResolvedBackend?) -> some View {
        if let backend {
            accountWarning(backend).schemaWarning(backend)
        } else {
            self
        }
    }
}
