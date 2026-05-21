//
//  NimbusError+SwiftUI.swift
//  NimbusSwiftUI
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit

extension NimbusError.Domain {
    static let swiftui = Self(rawValue: "swiftui")
}

extension NimbusError {
    static func swiftui(reason: Reason = .failure, stage: Stage, detail: String? = nil) -> NimbusError {
        NimbusError(reason: reason, domain: .swiftui, stage: stage, detail: detail)
    }
}
