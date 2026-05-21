//
//  View+Then.swift
//  NimbusSwiftUI
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI

extension View {
    @inlinable
    func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        body(&result)
        return result
    }
}
