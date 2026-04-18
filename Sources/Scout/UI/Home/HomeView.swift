//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI
import UIKit

public struct HomeView: View {
    let container: CKContainer

    @StateObject private var tint = Tint()

    public init(container: CKContainer) {
        self.container = container
    }

    public var body: some View {
        NavigationStack {
            HomeContent()
                .navigationBarTitle("Home")
        }
        .dismissable()
        .onboardingSheet()
        .iCloudWarning(container: container)
        .schemaWarning(container: container)
        .tint(tint.value)
        .environmentObject(tint)
        .environment(\.database, container.publicCloudDatabase)
    }
}
