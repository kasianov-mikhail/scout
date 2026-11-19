//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import SwiftUI

struct SettingsOverviewView: View {
    @Binding var activeID: String
    @StateObject var health: BackendHealthProvider
    @StateObject var cacheStatus: CacheStatus

    let send: SendSummary

    @State var start = StartPeriod.today
    @State var pushes = true
    @State var isClearing = false

    init(backends: [Backend], activeID: Binding<String>, cache: any CacheClearing, health: BackendHealthProvider? = nil, send: SendSummary) {
        self._activeID = activeID
        self.send = send
        self._health = StateObject(wrappedValue: health ?? BackendHealthProvider(backends: backends))
        self._cacheStatus = StateObject(wrappedValue: CacheStatus(cache: cache))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    readFromSection
                    startOnSection
                    alertPushesSection
                    sendingSection
                    cacheSection
                    versionLabel
                }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Settings")
        .inlineNavigationTitle()
        .dismissable()
        .fetchTask([health])
        .task {
            await cacheStatus.refresh()
        }
        .confirmationDialog(
            Text(verbatim: "Clear the cached data?"),
            isPresented: $isClearing,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                Task { await cacheStatus.clear() }
            } label: {
                Text(verbatim: "Clear Cache")
            }

            Button(role: .cancel) {
            } label: {
                Text(verbatim: "Cancel")
            }
        } message: {
            Text(verbatim: "Charts and lists will reload from the backend on their next refresh.")
        }
    }
}
