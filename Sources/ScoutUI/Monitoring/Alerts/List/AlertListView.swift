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
    @State private var selected: AlertStatus?

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
            .inlineNavigationTitle()
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

    private func list(_ statuses: [AlertStatus]) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if provider.notificationsDenied, statuses.contains(where: \.rule.notifies) {
                NotificationsDeniedRow()
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
                    .padding(.horizontal, .gutter)
            }

            AlertListLegend()
                .padding(.top, .space10)
                .padding(.horizontal, .gutter)

            section(statuses.firing, title: "Firing")
            section(statuses.armed, title: "Armed")
            section(statuses.muted, title: "Muted")
        }
    }

    @ViewBuilder private func section(_ statuses: [AlertStatus], title: String) -> some View {
        if !statuses.isEmpty {
            Section(title: title) {
                Text(verbatim: "\(statuses.count)")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            } content: {
                ForEach(Array(statuses.enumerated()), id: \.element.rule) { index, status in
                    AlertRuleRow(
                        status: status,
                        isLast: index == statuses.count - 1,
                        onDelete: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                provider.remove(status.rule)
                            }
                        },
                        onMute: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                provider.mute(status.rule, until: Date().addingTimeInterval(3600))
                            }
                        },
                        onOpen: {
                            selected = status
                        }
                    )
                    .padding(.horizontal, -.gutter)
                }
            }
        }
    }
}

struct AlertListLegend: View {
    var showsAxis = true

    var body: some View {
        VStack(alignment: .leading, spacing: .space4) {
            HStack {
                Text(verbatim: "24 h ago")
                Spacer()
                Text(verbatim: "12 h")
                Spacer()
                Text(verbatim: "now")
            }
            .font(.scoutAxis)
            .foregroundStyle(Color.textMuted)
            .opacity(showsAxis ? 1 : 0)

            HStack(spacing: .space12) {
                legendItem(color: Color.fillLevel, title: "breached")
                legendItem(color: Color.textDanger, title: "firing now")
            }
            .font(.scoutFootnote)
            .foregroundStyle(Color.textMuted)
        }
        .padding(.bottom, .space16)
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: .space4) {
            RoundedRectangle(cornerRadius: .radiusBar)
                .fill(color)
                .frame(width: 10, height: 10)

            Text(verbatim: title)
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
