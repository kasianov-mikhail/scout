//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSection: View {
    private enum Destination: Hashable {
        case releaseHealth
    }

    let adoption: ReleaseAdoption
    let releases: ReleaseHealthProvider
    let zoom: Namespace.ID

    @Binding private var path: NavigationPath

    init(adoption: ReleaseAdoption, releases: ReleaseHealthProvider, zoom: Namespace.ID, path: Binding<NavigationPath>) {
        self.adoption = adoption
        self.releases = releases
        self.zoom = zoom
        self._path = path
    }

    var body: some View {
        section.navigationDestination(for: Destination.self) { destination in
            ReleaseHealthView(provider: releases)
                .zoomTransition(destination, in: zoom)
        }
    }

    private var section: some View {
        Group {
            if adoption.isEmpty {
                Empty(onShowAll: showAll)
            } else {
                content(adoption: adoption)
            }
        }
        .zoomSource(Destination.releaseHealth, in: zoom)
        .contentShape(Rectangle())
        .onTapGesture(perform: showAll)
    }

    private func showAll() {
        path.append(Destination.releaseHealth)
    }

    private func content(adoption: ReleaseAdoption) -> some View {
        Section(title: "Releases", bottomGap: .space10) {
            HomeSectionExpandButton(action: showAll)
                .accessibilityLabel(Text(verbatim: "Show all releases"))
        } content: {
            HStack(alignment: .firstTextBaseline, spacing: .space8) {
                Text(verbatim: adoption.headline)
                    .font(.scoutNumberM)

                Text(verbatim: "of sessions")
                    .font(.scoutRow)
                    .foregroundStyle(Color.textMuted)
            }
            .frame(height: 28)
            .padding(.top, 14)

            AdoptionBar(
                versions: adoption.versions,
                height: 24,
                labelSize: 10,
                labelWeight: .semibold,
                labelInset: 6
            )
            .padding(.top, .space10)

            AdoptionLegend(squareSize: 7, squareColor: nil)
                .padding(.top, .space8)

            caption(adoption: adoption)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }

    @ViewBuilder
    private func caption(adoption: ReleaseAdoption) -> some View {
        if let top = adoption.top {
            (Text(verbatim: "\(top.id) is ")
                .foregroundColor(Color.textMuted)
                + Text(verbatim: top.stability.level.title)
                .font(.scoutCaptionStrong)
                .foregroundColor(top.stability.level == .healthy ? Color.positive : top.stability.level.labelColor)
                + Text(verbatim: " at \(top.stability.formatted) crash-free\(top.shippedLabel)")
                .foregroundColor(Color.textMuted))
                .font(.scoutCaption)
                .lineLimit(1)
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @Namespace var zoom
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeReleaseSection(
                    adoption: .sample,
                    releases: ReleaseHealthProvider(.success(.samples)),
                    zoom: zoom,
                    path: $path
                )
                HomeReleaseSection.Placeholder()
            }
        }
        .scrollIndicators(.hidden)
    }
    .environmentObject(Tint())
}
