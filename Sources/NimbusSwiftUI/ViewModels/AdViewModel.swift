//
//  AdView.swift
//  NimbusSwiftUI
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI
import NimbusKit

@Observable
@MainActor
@_documentation(visibility: internal)
public class AdViewModel<T: Ad> {
    let ad: T
    
    @ObservationIgnored public var onEvent: ((AdEvent) -> Void)?
    @ObservationIgnored public var onError: ((NimbusError) -> Void)?
    
    init(ad: T) {
        self.ad = ad
        ad.onEvent { [weak self] event in self?.didReceive(event: event) }
        ad.onError { [weak self] error in self?.didReceive(error: error) }
    }
    
    func didReceive(event: AdEvent) {
        onEvent?(event)
    }
    
    func didReceive(error: NimbusError) {
        onError?(error)
    }
}
