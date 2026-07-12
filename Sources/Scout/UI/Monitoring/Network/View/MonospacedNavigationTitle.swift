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
            private var restore: ((UINavigationBar) -> Void)?

            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)

                if let bar = navigationController?.navigationBar {
                    restore = { bar in
                        for appearance in bar.allAppearances {
                            appearance.largeTitleTextAttributes = bar.standardAppearance.largeTitleTextAttributes
                            appearance.titleTextAttributes = bar.standardAppearance.titleTextAttributes
                        }
                    }

                    for appearance in bar.allAppearances {
                        appearance.largeTitleTextAttributes[.font] = UIFont.monospacedSystemFont(ofSize: 24, weight: .bold)
                        appearance.titleTextAttributes[.font] = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
                    }
                }
            }

            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)

                if let bar = navigationController?.navigationBar {
                    restore?(bar)
                }
            }
        }
    }

    extension UINavigationBar {
        fileprivate var allAppearances: [UINavigationBarAppearance] {
            [standardAppearance, compactAppearance, scrollEdgeAppearance, compactScrollEdgeAppearance].compactMap(\.self)
        }
    }

#endif
