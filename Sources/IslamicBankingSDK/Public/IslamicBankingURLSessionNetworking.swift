import Foundation

/// Maps each SDK endpoint to a relative API path (and optional metadata).
public struct IslamicBankingEndpointRoute {
    public let path: String
    /// Optional host-specific fields merged into every request for this endpoint (e.g. appId / appKey).
    public let extraParameters: [String: Any]

    public init(path: String, extraParameters: [String: Any] = [:]) {
        self.path = path
        self.extraParameters = extraParameters
    }
}

/// Default route table using the standard Murabaha method names as path segments.
/// Override paths/extra params to match your backend.
public struct IslamicBankingRouteTable {
    public var fetchApplications: IslamicBankingEndpointRoute
    public var storeDeclaration: IslamicBankingEndpointRoute
    public var uploadInvoice: IslamicBankingEndpointRoute
    public var fetchRepaymentPlan: IslamicBankingEndpointRoute

    public init(
        fetchApplications: IslamicBankingEndpointRoute = .init(path: "fetchMurabahaApplications"),
        storeDeclaration: IslamicBankingEndpointRoute = .init(path: "storeMurabahaDeclaration"),
        uploadInvoice: IslamicBankingEndpointRoute = .init(path: "uploadMurabahaInvoice"),
        fetchRepaymentPlan: IslamicBankingEndpointRoute = .init(path: "fetchMurabahaRepaymentPlan")
    ) {
        self.fetchApplications = fetchApplications
        self.storeDeclaration = storeDeclaration
        self.uploadInvoice = uploadInvoice
        self.fetchRepaymentPlan = fetchRepaymentPlan
    }

    public func route(for endpoint: IslamicBankingEndpoint) -> IslamicBankingEndpointRoute {
        switch endpoint {
        case .fetchApplications: return fetchApplications
        case .storeDeclaration: return storeDeclaration
        case .uploadInvoice: return uploadInvoice
        case .fetchRepaymentPlan: return fetchRepaymentPlan
        }
    }
}

/// Built-in `URLSession` networking so any host can use the SDK without a custom API stack.
///
/// Requests are **POST** with `application/json` body =
/// `defaultParameters` + route `extraParameters` + SDK `parameters`.
@objc public final class IslamicBankingURLSessionNetworking: NSObject, IslamicBankingNetworking {

    public let baseURL: URL
    public let routes: IslamicBankingRouteTable
    public let defaultParameters: [String: Any]
    public let session: URLSession
    public let successHTTPStatusCodes: Set<Int>

    /// - Parameters:
    ///   - baseURL: API root, e.g. `https://api.example.com/`
    ///   - routes: Path (+ optional extra params) per endpoint
    ///   - defaultParameters: Merged into every request (session id, device info, …)
    ///   - session: Defaults to `URLSession.shared`
    ///   - successHTTPStatusCodes: Treated as transport success (default `200..<300`)
    public init(
        baseURL: URL,
        routes: IslamicBankingRouteTable = IslamicBankingRouteTable(),
        defaultParameters: [String: Any] = [:],
        session: URLSession = .shared,
        successHTTPStatusCodes: Set<Int> = Set(200..<300)
    ) {
        self.baseURL = baseURL
        self.routes = routes
        self.defaultParameters = defaultParameters
        self.session = session
        self.successHTTPStatusCodes = successHTTPStatusCodes
        super.init()
    }

    public func performRequest(
        endpoint: IslamicBankingEndpoint,
        parameters: [String: Any],
        headers: [String: String],
        showLoading: Bool,
        completion: @escaping ([String: Any]?, String?, Bool) -> Void
    ) {
        let route = routes.route(for: endpoint)
        let url = baseURL.appendingPathComponent(route.path)

        var body: [String: Any] = defaultParameters
        route.extraParameters.forEach { body[$0.key] = $0.value }
        parameters.forEach { body[$0.key] = $0.value }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            DispatchQueue.main.async {
                completion(nil, "Unable to encode request parameters.", false)
            }
            return
        }

        // `showLoading` is handled by the host UI delegate if provided; URLSession itself is silent.
        _ = showLoading

        session.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(nil, error.localizedDescription, false)
                }
                return
            }

            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let ok = self.successHTTPStatusCodes.contains(status)

            guard let data, !data.isEmpty else {
                DispatchQueue.main.async {
                    completion(nil, ok ? "Empty response." : "Request failed (\(status)).", ok)
                }
                return
            }

            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            let message = (json?["msg"] as? String)
                ?? (json?["message"] as? String)
                ?? (ok ? nil : "Request failed (\(status)).")

            DispatchQueue.main.async {
                completion(json, message, ok)
            }
        }.resume()
    }
}

/// Simple token / header auth provider.
@objc public final class IslamicBankingTokenAuth: NSObject, IslamicBankingAuthProviding {
    private let headerProvider: () -> [String: String]

    public init(headers: [String: String]) {
        self.headerProvider = { headers }
        super.init()
    }

    public init(headerProvider: @escaping () -> [String: String]) {
        self.headerProvider = headerProvider
        super.init()
    }

    /// Convenience: `Authorization: <token>`
    public convenience init(authorizationToken: String) {
        self.init(headers: ["Authorization": authorizationToken])
    }

    public func islamicBankingHeaders() -> [String: String] {
        headerProvider()
    }
}
