Pod::Spec.new do |spec|
    spec.name                   = 'NimbusSwiftUI'
    spec.version                = '0.0.1-development'
    spec.summary                = 'Nimbus SwiftUI extension'
    spec.homepage               = 'https://www.adsbynimbus.com'
    spec.social_media_url       = 'https://twitter.com/adsbynimbus'
    spec.author                 = 'Nimbus'
    spec.platform               = :ios, '17.0'
    spec.documentation_url      = 'https://docs.adsbynimbus.com/docs/sdk/ios'
    spec.license                = { :type => 'Copyright', :text => 'Nimbus. All rights reserved.' }
    spec.swift_versions         = ['5', '6']
    spec.ios.deployment_target  = '17.0'
    spec.static_framework       = true
    spec.source_files           = "Sources/NimbusSwiftUI/**/*.swift"
    spec.source                 = {
        :git => "https://github.com/adsbynimbus/nimbus-ios-swiftui.git",
        :tag => spec.version.to_s
    }
end
