//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func onboardingSheet() -> some View {
        modifier(OnboardingSheetModifier())
    }
}

private struct OnboardingSheetModifier: ViewModifier {
    @AppStorage("scout_onboarding_completed") private var completed = false

    func body(content: Content) -> some View {
        content.sheet(
            isPresented: .init(
                get: { !completed },
                set: { completed = !$0 }
            )
        ) {
            OnboardingView()
        }
    }
}
