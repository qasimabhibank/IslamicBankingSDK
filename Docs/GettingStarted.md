# Getting Started

## 1. Add the package from GitHub

**Xcode → File → Add Package Dependencies…**

```text
https://github.com/YOUR_ORG/IslamicBankingSDK.git
```

Select **IslamicBankingSDK** for your app target.

---

## 2. Configure after the user has a session

```swift
import IslamicBankingSDK

func setupIslamicBanking(accessToken: String) {
    let networking = IslamicBankingURLSessionNetworking(
        baseURL: URL(string: "https://api.your-bank.com/")!,
        routes: IslamicBankingRouteTable(
            fetchApplications: .init(
                path: "fetchMurabahaApplications",
                extraParameters: ["appId": "…", "appKey": "…"]
            ),
            storeDeclaration: .init(
                path: "storeMurabahaDeclaration",
                extraParameters: ["appId": "…", "appKey": "…"]
            ),
            uploadInvoice: .init(
                path: "uploadMurabahaInvoice",
                extraParameters: ["appId": "…", "appKey": "…"]
            ),
            fetchRepaymentPlan: .init(
                path: "fetchMurabahaRepaymentPlan",
                extraParameters: ["appId": "…", "appKey": "…"]
            )
        ),
        defaultParameters: [
            // device / session fields your API requires
        ]
    )

    IslamicBanking.configure(
        IslamicBankingConfiguration(
            networking: networking,
            auth: IslamicBankingTokenAuth(authorizationToken: "Bearer \(accessToken)")
        )
    )
}
```

Call this **once** after login (or whenever the token is ready).

---

## 3. Open the flow from any button

```swift
@IBAction func openIslamicBanking(_ sender: UIButton) {
    guard IslamicBanking.isConfigured else {
        // configure first
        return
    }
    IslamicBanking.startFlow(from: self)
}
```

---

## 4. Smoke test checklist

- [ ] Package resolves in Xcode
- [ ] `configure` does not crash
- [ ] Intro screen appears
- [ ] Proposals load (or empty / error alert)
- [ ] Declaration / invoice / offer popups work
- [ ] Success screen dismisses correctly

---

## 5. Using your own API client

Implement `IslamicBankingNetworking` and pass it into `IslamicBankingConfiguration` instead of `IslamicBankingURLSessionNetworking`.

See [API.md](API.md) for the full contract.

---

## 6. Troubleshooting

| Issue | Fix |
|-------|-----|
| `configure must be called` crash | Call `IslamicBanking.configure` before `startFlow` |
| Missing images / blank UI | Ensure product **IslamicBankingSDK** is linked to the target that presents the flow |
| 401 errors | Check `IslamicBankingAuthProviding` / token |
| Wrong URL | Adjust `baseURL` + `IslamicBankingRouteTable` paths |
