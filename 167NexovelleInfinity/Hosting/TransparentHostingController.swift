//
//  TransparentHostingController.swift
//  167NexovelleInfinity
//

import SwiftUI
import UIKit

/// UIHostingController defaults to an opaque white `view`; that paints over any SwiftUI-clear areas.
final class TransparentHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground") ?? .systemBackground
        view.isOpaque = true
    }
}
