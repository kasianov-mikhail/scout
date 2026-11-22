//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertListView: View {
    @ObservedObject var provider: AlertProvider

    @Environment(\.database) private var database
    @State private var creation: Creation?
    @State var selected: AlertStatus?

    private enum Creation: String, Identifiable {
        case composer
        case templates

        var id: String { rawValue }
    }

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: provider.isLoading)
            .loadingInk(isLoading: provider.isLoading)
            .navigationTitle(en: "Alerts")
            .inlineNavigationTitle(divider: nil)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            creation = .composer
                        } label: {
                            Text(verbatim: "New Alert")
                        }

                        Button {
                            creation = .templates
                        } label: {
                            Text(verbatim: "From Template")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $creation) {
                Task { await provider.fetchLatest(in: database) }
            } content: { creation in
                switch creation {
                case .composer:
                    NavigationStack {
                        AlertComposerView(provider: provider)
                    }
                    .opaquePresentation()
                case .templates:
                    AlertTemplateListView(provider: provider)
                        .opaquePresentation()
                }
            }
            .navigationDestination(isPresented: Binding(get: { selected != nil }, set: { if !$0 { selected = nil } })) {
                if let selected {
                    AlertDetailView(provider: provider, rule: selected.rule, status: selected)
                }
            }
            .task {
                await provider.fetchIfNeeded(in: database)
            }
            .notificationStatus(of: provider)
    }

    @ViewBuilder private var content: some View {
        if let error = provider.error {
            ErrorView(description: error.localizedDescription) {
                await provider.fetchAgain(in: database)
            }
        } else if case .success(let statuses) = provider.result, statuses.isEmpty {
            Placeholder(
                text: "No alert rules",
                systemImage: "bell.badge",
                description: "Add a rule to get notified when a metric misbehaves."
            )
        } else {
            ScrollView {
                if case .success(let statuses) = provider.result {
                    list(statuses)
                        .transition(.opacity)
                } else {
                    AlertListPlaceholder()
                        .transition(.opacity)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview("Alerts") {
    NavigationStack {
        AlertListView(provider: .init(.success(AlertStatus.samples)))
    }
}

#Preview("Empty") {
    NavigationStack {
        AlertListView(provider: .init(.success([])))
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertListView(provider: .init())
    }
}
