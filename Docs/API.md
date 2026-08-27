# API Reference

## `IslamicBanking`

Entry point.

| Method / Property | Description |
|-------------------|-------------|
| `configure(_:)` | Stores host networking + auth. Call once. |
| `startFlow(from:)` | Presents Murabaha UI modally (`overFullScreen`). |
| `isConfigured` | `true` after successful `configure`. |
| `resourceBundle` | SPM resource bundle (`Bundle.module`). |

Obj-C selector for start: `startFlowFrom:`.

---

## `IslamicBankingConfiguration`

```swift
IslamicBankingConfiguration(
    networking: IslamicBankingNetworking,
    auth: IslamicBankingAuthProviding,
    uiDelegate: IslamicBankingUIDelegate? = nil,
    noInternetMessage: String = "Please check your internet connection and try again."
)
```

---

## `IslamicBankingEndpoint`

```swift
enum IslamicBankingEndpoint: Int {
    case fetchApplications
    case storeDeclaration
    case uploadInvoice
    case fetchRepaymentPlan
}
```

`methodName` returns the default path segment string for each case.

---

## `IslamicBankingNetworking`

```swift
func performRequest(
    endpoint: IslamicBankingEndpoint,
    parameters: [String: Any],
    headers: [String: String],
    showLoading: Bool,
    completion: @escaping (_ json: [String: Any]?, _ message: String?, _ isSuccessful: Bool) -> Void
)
```

**Rules**

- Call `completion` on the **main** queue (built-in URLSession client already does).
- `isSuccessful` = transport/HTTP success (not business `code`).
- SDK validates `code == 200` after decoding.

### Parameters filled by the SDK

**storeDeclaration**

- `applicationId: Int`
- `offerToPurchase: Bool`
- `declaration: Bool`

**uploadInvoice**

- `applicationId: Int`
- `imageName: String`
- `imageExt: String`
- `invoice: String` (JPEG base64)

**fetchRepaymentPlan**

- `applicationId: Int`

---

## `IslamicBankingAuthProviding`

```swift
func islamicBankingHeaders() -> [String: String]
```

Example: `["Authorization": "Bearer …"]`

---

## `IslamicBankingUIDelegate` (optional)

```swift
optional func islamicBankingShowError(title: String, message: String)
optional func islamicBankingShowLoading(_ show: Bool)
```

If omitted, the SDK shows a standard `UIAlertController` for errors.

---

## Built-in helpers

### `IslamicBankingURLSessionNetworking`

POST JSON to `baseURL + route.path`.

Merges: `defaultParameters` → route `extraParameters` → SDK `parameters`.

### `IslamicBankingRouteTable` / `IslamicBankingEndpointRoute`

Customize path and per-endpoint extra fields (appId, appKey, …).

### `IslamicBankingTokenAuth`

Static headers or a closure that returns headers on each request.

---

## Expected response JSON

```json
{
  "code": 200,
  "msg": "OK",
  "data": {}
}
```

`data` may be an array (applications / repayment plan) or an object (declaration / invoice).
