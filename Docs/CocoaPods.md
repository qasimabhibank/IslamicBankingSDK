# Install via CocoaPods

> SPM is recommended. CocoaPods is also supported via `IslamicBankingSDK.podspec`.

## 1. Publish the repo (once)

Push the package to GitHub and tag `1.0.0` (see [PUBLISH.md](PUBLISH.md)).

Replace `YOUR_ORG` in `IslamicBankingSDK.podspec` with your GitHub org/user.

## 2. Consumer Podfile

### From GitHub tag (recommended)

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'IslamicBankingSDK', :git => 'https://github.com/YOUR_ORG/IslamicBankingSDK.git', :tag => '1.0.0'
end
```

### From branch

```ruby
pod 'IslamicBankingSDK', :git => 'https://github.com/YOUR_ORG/IslamicBankingSDK.git', :branch => 'main'
```

### From CocoaPods trunk (after `pod trunk push`)

```ruby
pod 'IslamicBankingSDK', '~> 1.0'
```

## 3. Install

```bash
pod install
```

Open the `.xcworkspace`.

## 4. Use in code

Same as SPM:

```swift
import IslamicBankingSDK

IslamicBanking.configure(...)
IslamicBanking.startFlow(from: self)
```

## 5. Optional — publish to CocoaPods Trunk

Requires a CocoaPods account:

```bash
pod trunk register you@email.com 'Your Name'
# confirm email, then from the package root:
pod lib lint IslamicBankingSDK.podspec --allow-warnings
pod trunk push IslamicBankingSDK.podspec --allow-warnings
```

Until trunk publish, consumers should use the `:git` / `:tag` Podfile form above.
