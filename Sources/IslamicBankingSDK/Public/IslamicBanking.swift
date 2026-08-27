import UIKit

/// Public entry point for the Islamic Banking (Murabaha) SDK.
@objc public final class IslamicBanking: NSObject {

    private static var configuration: IslamicBankingConfiguration?
    static var config: IslamicBankingConfiguration {
        guard let configuration else {
            fatalError("IslamicBanking.configure(_:) must be called before using the SDK.")
        }
        return configuration
    }

    /// Call once at app launch (or before presenting the flow) with host networking/auth.
    @objc public static func configure(_ configuration: IslamicBankingConfiguration) {
        self.configuration = configuration
    }

    /// Whether `configure` has been called.
    @objc public static var isConfigured: Bool {
        configuration != nil
    }

    /// Presents the Murabaha financing flow modally.
    @objc(startFlowFrom:)
    public static func startFlow(from viewController: UIViewController) {
        _ = config
        FPIslamicBankingFlowHelper.startFlow(from: viewController)
    }

    /// Bundle that contains storyboards, XIBs, and assets shipped with the SDK.
    public static var resourceBundle: Bundle {
        .module
    }
}
