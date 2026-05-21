//
//  Representable.swift
//  NimbusSwiftUI
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI

struct UIViewControllerHost: UIViewControllerRepresentable {
    let onReady: (UIViewController) async -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        Task { await onReady(vc) }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct UIViewHost: UIViewRepresentable {
    let onReady: (UIView) async -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        Task { await onReady(view) }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
