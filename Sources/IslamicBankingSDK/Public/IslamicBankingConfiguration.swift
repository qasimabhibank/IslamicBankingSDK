import Foundation
import UIKit

/// Endpoint identifiers used by the Murabaha APIs.
@objc public enum IslamicBankingEndpoint: Int {
    case fetchApplications
    case storeDeclaration
    case uploadInvoice
    case fetchRepaymentPlan

    public var methodName: String {
        switch self {
        case .fetchApplications: return "fetchMurabahaApplications"
        case .storeDeclaration: return "storeMurabahaDeclaration"
        case .uploadInvoice: return "uploadMurabahaInvoice"
        case .fetchRepaymentPlan: return "fetchMurabahaRepaymentPlan"
        }
    }
}

/// Host app implements this to perform authenticated API calls.
@objc public protocol IslamicBankingNetworking: AnyObject {
    /// Perform a POST (or multipart-style) request and return a JSON dictionary.
    /// - Parameters:
    ///   - endpoint: Which Murabaha API to call.
    ///   - parameters: Body parameters (already includes flow-specific fields).
    ///   - headers: Extra headers (e.g. Authorization).
    ///   - showLoading: Whether the host should show a HUD/spinner.
    ///   - completion: `json` is the top-level response dictionary; `isSuccessful` mirrors host success rules.
    func performRequest(
        endpoint: IslamicBankingEndpoint,
        parameters: [String: Any],
        headers: [String: String],
        showLoading: Bool,
        completion: @escaping (_ json: [String: Any]?, _ message: String?, _ isSuccessful: Bool) -> Void
    )
}

/// Supplies auth headers for Islamic Banking requests.
@objc public protocol IslamicBankingAuthProviding: AnyObject {
    /// Example: `["Authorization": "<base64 token>"]`
    func islamicBankingHeaders() -> [String: String]
}

/// Optional UI hooks (alerts / loading). If nil, the SDK uses simple `UIAlertController`s.
@objc public protocol IslamicBankingUIDelegate: AnyObject {
    @objc optional func islamicBankingShowError(title: String, message: String)
    @objc optional func islamicBankingShowLoading(_ show: Bool)
}

/// Configuration injected by the host application.
@objc public final class IslamicBankingConfiguration: NSObject {
    public let networking: IslamicBankingNetworking
    public let auth: IslamicBankingAuthProviding
    public weak var uiDelegate: IslamicBankingUIDelegate?
    public let noInternetMessage: String

    @objc public init(
        networking: IslamicBankingNetworking,
        auth: IslamicBankingAuthProviding,
        uiDelegate: IslamicBankingUIDelegate? = nil,
        noInternetMessage: String = "Please check your internet connection and try again."
    ) {
        self.networking = networking
        self.auth = auth
        self.uiDelegate = uiDelegate
        self.noInternetMessage = noInternetMessage
        super.init()
    }
}
