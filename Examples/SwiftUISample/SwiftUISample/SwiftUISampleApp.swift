//
//  SwiftUISampleApp.swift
//  SwiftUISample
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI
import NimbusKit

@main
struct SwiftUISampleApp: App {
    
    init() {
        Nimbus.initialize(
            publisherKey: Bundle.main.infoDictionary?["Publisher Key"] as! String,
            apiKey: Bundle.main.infoDictionary?["API Key"] as! String,
        )
        Nimbus.configuration.testMode = true
        
        // This is a specific test endpoint, DO NOT use in production
        Nimbus.configuration.requestUrl = URL(string: "https://dev-sdk.adsbynimbus.com/rta/test")!
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
