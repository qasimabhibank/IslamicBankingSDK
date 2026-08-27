# IslamicBankingSDK

Standalone **iOS Swift Package** that presents a complete **Islamic Banking (Murabaha)** UI flow:

Intro → My Proposals → Declaration / Invoice / Offer → Repayment Plan → Success

The SDK owns UI + flow. **Your app owns networking & auth** (or use the built-in `URLSession` client).

---

## Requirements

| Item | Version |
|------|---------|
| iOS | 13.0+ |
| Swift | 5.9+ |
| Xcode | 15+ |
| UI | UIKit |

**No FINCAPay dependency.** Install via **SPM** or **CocoaPods**.

---

## Installation

### A) Swift Package Manager (recommended)

**Xcode:** File → Add Package Dependencies… → paste:

```text
https://github.com/YOUR_ORG/IslamicBankingSDK.git
```

Version rule: **Up to Next Major** from `1.0.0` → add product **IslamicBankingSDK**.

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_ORG/IslamicBankingSDK.git", from: "1.0.0")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "IslamicBankingSDK", package: "IslamicBankingSDK")
    ]
)
```

### B) CocoaPods

```ruby
pod 'IslamicBankingSDK', :git => 'https://github.com/YOUR_ORG/IslamicBankingSDK.git', :tag => '1.0.0'
```

```bash
pod install
```

Full Pods guide: [Docs/CocoaPods.md](Docs/CocoaPods.md)

---

## Quick start (3 steps)

### 1. Configure once (e.g. after login)

```swift
import IslamicBankingSDK

let networking = IslamicBankingURLSessionNetworking(
    baseURL: URL(string: "https://api.your-bank.com/")!,
    routes: IslamicBankingRouteTable() // customize paths / appId if needed
)

let auth = IslamicBankingTokenAuth(authorizationToken: "Bearer \(accessToken)")

IslamicBanking.configure(
    IslamicBankingConfiguration(
        networking: networking,
        auth: auth
    )
)
```

### 2. Present on button tap

```swift
@IBAction func islamicBankingTapped(_ sender: Any) {
    IslamicBanking.startFlow(from: self)
}
```

### 3. Done

The SDK presents a modal navigation stack with the full Murabaha journey.

> Full copy-paste sample: [`Examples/BasicHostIntegration.swift`](Examples/BasicHostIntegration.swift)

---

## Architecture

```text
┌─────────────────────────────┐
│         Host App            │
│  configure(networking,auth) │
│  startFlow(from:)           │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│      IslamicBankingSDK      │
│  UI (storyboard / XIBs)     │
│  ViewModels / Models        │
│  Calls IslamicBankingNetworking
└─────────────────────────────┘
```

| Layer | Owner |
|-------|--------|
| Screens, assets, navigation | SDK |
| HTTP / certificates / tokens | Host (or built-in URLSession helper) |
| Backend URLs & app keys | Host |

---

## Public API

| Symbol | Purpose |
|--------|---------|
| `IslamicBanking.configure(_:)` | Inject networking + auth (**required**) |
| `IslamicBanking.startFlow(from:)` | Present Murabaha flow |
| `IslamicBanking.isConfigured` | Configuration check |
| `IslamicBanking.resourceBundle` | Bundle for storyboards / assets |
| `IslamicBankingURLSessionNetworking` | Ready-made URLSession client |
| `IslamicBankingTokenAuth` | Simple header / Bearer auth |
| `IslamicBankingRouteTable` | Map endpoints → API paths |
| `IslamicBankingNetworking` | Protocol if you use your own API stack |
| `IslamicBankingAuthProviding` | Protocol for auth headers |
| `IslamicBankingUIDelegate` | Optional alerts / loading HUD |

---

## API endpoints the SDK calls

| `IslamicBankingEndpoint` | Default path | Typical body fields (SDK fills) |
|--------------------------|--------------|----------------------------------|
| `.fetchApplications` | `fetchMurabahaApplications` | (host defaults only) |
| `.storeDeclaration` | `storeMurabahaDeclaration` | `applicationId`, `offerToPurchase`, `declaration` |
| `.uploadInvoice` | `uploadMurabahaInvoice` | `applicationId`, `imageName`, `imageExt`, `invoice` (base64) |
| `.fetchRepaymentPlan` | `fetchMurabahaRepaymentPlan` | `applicationId` |

Expected JSON shape (business success):

```json
{ "code": 200, "msg": "...", "data": { } }
```

`code != 200` is treated as a business error inside the SDK.

---

## Custom networking (optional)

If you already have Alamofire / Moya / an in-house client:

```swift
final class MyNetworking: NSObject, IslamicBankingNetworking {
    func performRequest(
        endpoint: IslamicBankingEndpoint,
        parameters: [String: Any],
        headers: [String: String],
        showLoading: Bool,
        completion: @escaping ([String: Any]?, String?, Bool) -> Void
    ) {
        // Call your API, then:
        completion(jsonDictionary, errorMessage, isHTTPSuccessful)
    }
}
```

---

## Obj-C

```objc
#import <IslamicBankingSDK/IslamicBankingSDK-Swift.h>

[IslamicBanking configure:config];
[IslamicBanking startFlowFrom:self];
```

---

## Documentation

| Doc | Description |
|-----|-------------|
| [Docs/GettingStarted.md](Docs/GettingStarted.md) | Integration walkthrough |
| [Docs/API.md](Docs/API.md) | API reference |
| [Docs/PUBLISH.md](Docs/PUBLISH.md) | How to publish this folder to GitHub |
| [CHANGELOG.md](CHANGELOG.md) | Version history |

---

## Folder structure

```text
IslamicBankingSDK/          ← this folder IS the Swift package root
├── Package.swift
├── README.md
├── LICENSE
├── CHANGELOG.md
├── Docs/
├── Examples/
└── Sources/IslamicBankingSDK/
    ├── Public/       # API surface
    ├── Support/      # helpers
    ├── Internal/     # UI + view models
    └── Resources/    # storyboard, XIBs, assets
```

Clone / push **this folder as the repository root** (see [Docs/PUBLISH.md](Docs/PUBLISH.md)).

---

## License

See [LICENSE](LICENSE).
