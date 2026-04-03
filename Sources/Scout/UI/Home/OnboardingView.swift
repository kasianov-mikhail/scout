//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct OnboardingView: View {
    @State private var page: Int

    init(initialPage: Int = 0) {
        _page = State(initialValue: initialPage)
    }

    var body: some View {
        VStack {
            TabView(selection: $page) {
                WelcomePage().tag(0)
                SetupPage().tag(1)
                ReadyPage().tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// MARK: - Previews

#Preview("Page 1 – Welcome") {
    OnboardingView()
}

#Preview("Page 2 – Setup") {
    OnboardingView(initialPage: 1)
}

#Preview("Page 3 – Ready") {
    OnboardingView(initialPage: 2)
}
