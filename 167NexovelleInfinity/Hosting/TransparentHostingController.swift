//
//  TransparentHostingController.swift
//  167NexovelleInfinity
//

import SwiftUI
import UIKit

/// UIHostingController defaults to an opaque white `view`; that paints over any SwiftUI-clear areas.
final class TransparentHostingController: UIHostingController<AnyView> {
    init<Content: View>(rootView: Content) {
        super.init(rootView: AnyView(rootView))
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground") ?? .systemBackground
        view.isOpaque = true
    }
}
