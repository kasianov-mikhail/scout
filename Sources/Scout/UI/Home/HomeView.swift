//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

public struct HomeView: View {
    let database: any AppDatabase
    let container: CKContainer?

    @StateObject private var tint = Tint()

    public init(container: CKContainer) {
        self.database = container.publicCloudDatabase
        self.container = container
    }

    /// Reads analytics from the first backend in the list.
    ///
    /// CloudKit account and schema warnings only apply when that backend
    /// is a CloudKit container.
    ///
    public init(backends: [Backend]) {
        if let primary = backends.primaryDatabase {
            self.database = primary
        } else {
            self.database = DefaultDatabase()
        }

        if case .cloudKit(let container) = backends.first {
            self.container = container
        } else {
            self.container = nil
        }
    }

    public var body: some View {
        NavigationStack {
            HomeContent()
                .navigationTitle(en: "Home")
                .cloudKitWarnings(container: container)
                .dismissable()
        }
        .onboardingSheet()
        .tint(tint.value)
        .environmentObject(tint)
        .environment(\.database, database)
    }
}

extension View {
    @ViewBuilder fileprivate func cloudKitWarnings(container: CKContainer?) -> some View {
        if let container {
            iCloudWarning(container: container).schemaWarning(container: container)
        } else {
            self
        }
    }
}
