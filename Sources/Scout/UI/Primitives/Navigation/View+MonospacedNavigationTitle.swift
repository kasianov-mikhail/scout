//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension View {
    func monospacedNavigationTitle(en title: String) -> some View {
        #if canImport(UIKit)
            navigationTitle(en: title)
                .navigationBarTitleDisplayMode(.large)
                .background(MonospacedNavigationBar())
        #else
            navigationTitle(en: title)
        #endif
    }
}

#if canImport(UIKit)
    private struct MonospacedNavigationBar: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> Controller {
            Controller()
        }

        func updateUIViewController(_ controller: Controller, context: Context) {}

        final class Controller: UIViewController {
            private var originals: [TitleFonts] = []

            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)

                guard let bar = navigationController?.navigationBar else { return }

                originals = bar.allAppearances.map(TitleFonts.init)

                for appearance in bar.allAppearances {
                    appearance.largeTitleTextAttributes[.font] = UIFont.monospacedSystemFont(ofSize: 24, weight: .bold)
                    appearance.titleTextAttributes[.font] = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
                }
            }

            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                originals.forEach { $0.restore() }
            }
        }
    }

    @MainActor
    private struct TitleFonts {
        let appearance: UINavigationBarAppearance
        let largeTitle: UIFont?
        let title: UIFont?

        init(_ appearance: UINavigationBarAppearance) {
            self.appearance = appearance
            self.largeTitle = appearance.largeTitleTextAttributes[.font] as? UIFont
            self.title = appearance.titleTextAttributes[.font] as? UIFont
        }

        func restore() {
            appearance.largeTitleTextAttributes[.font] = largeTitle
            appearance.titleTextAttributes[.font] = title
        }
    }

    extension UINavigationBar {
        fileprivate var allAppearances: [UINavigationBarAppearance] {
            [standardAppearance, compactAppearance, scrollEdgeAppearance, compactScrollEdgeAppearance].compactMap(\.self)
        }
    }

#endif
