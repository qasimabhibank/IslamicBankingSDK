import Foundation
import UIKit
import IslamicBankingSDK

// MARK: - Drop this file into YOUR app (not into the SDK).
// Replace baseURL, auth token, and optional defaultParameters with your backend values.

final class AppIslamicBankingSetup {

    static func configure() {
        guard let baseURL = URL(string: "https://api.your-bank.com/") else { return }

        // Optional: attach appId / appKey (or any backend-required fields) per endpoint.
        let routes = IslamicBankingRouteTable(
            fetchApplications: .init(
                path: "fetchMurabahaApplications",
                extraParameters: ["appId": "YOUR_APP_ID", "appKey": "YOUR_APP_KEY"]
            ),
            storeDeclaration: .init(
                path: "storeMurabahaDeclaration",
                extraParameters: ["appId": "YOUR_APP_ID", "appKey": "YOUR_APP_KEY"]
            ),
            uploadInvoice: .init(
                path: "uploadMurabahaInvoice",
                extraParameters: ["appId": "YOUR_APP_ID", "appKey": "YOUR_APP_KEY"]
            ),
            fetchRepaymentPlan: .init(
                path: "fetchMurabahaRepaymentPlan",
                extraParameters: ["appId": "YOUR_APP_ID", "appKey": "YOUR_APP_KEY"]
            )
        )

        let networking = IslamicBankingURLSessionNetworking(
            baseURL: baseURL,
            routes: routes,
            defaultParameters: [
                // "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
                // "sessionId": currentSessionId
            ]
        )

        let auth = IslamicBankingTokenAuth {
            // Return a fresh token each call if needed
            ["Authorization": "Bearer YOUR_ACCESS_TOKEN"]
        }

        IslamicBanking.configure(
            IslamicBankingConfiguration(
                networking: networking,
                auth: auth
            )
        )
    }

    static func open(from viewController: UIViewController) {
        if !IslamicBanking.isConfigured {
            configure()
        }
        IslamicBanking.startFlow(from: viewController)
    }
}

/*
 Button example:

 @IBAction func islamicBankingTapped(_ sender: UIButton) {
     AppIslamicBankingSetup.open(from: self)
 }
*/
