Pod::Spec.new do |s|
  s.name             = 'IslamicBankingSDK'
  s.version          = '1.0.0'
  s.summary          = 'Standalone Islamic Banking (Murabaha) UIKit SDK for iOS.'
  s.description      = <<-DESC
    IslamicBankingSDK presents a complete Murabaha financing flow:
    intro, proposals, declaration, invoice upload, offer to purchase,
    repayment plan, and success screens.

    The host app supplies networking and auth (or uses the built-in URLSession client).
  DESC

  s.homepage         = 'https://github.com/YOUR_ORG/IslamicBankingSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'FINCA' => 'support@example.com' }
  s.source           = {
    :git => 'https://github.com/YOUR_ORG/IslamicBankingSDK.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '13.0'
  s.swift_version         = '5.9'
  s.requires_arc          = true

  s.source_files = 'Sources/IslamicBankingSDK/**/*.{swift}'
  s.resources    = [
    'Sources/IslamicBankingSDK/Resources/**/*.{storyboard,xib,xcassets,png,jpg,jpeg,pdf}'
  ]

  s.frameworks = 'UIKit', 'Foundation'

  # Exclude SPM-only / non-source clutter if present
  s.exclude_files = [
    'Sources/IslamicBankingSDK/**/*.md'
  ]
end
