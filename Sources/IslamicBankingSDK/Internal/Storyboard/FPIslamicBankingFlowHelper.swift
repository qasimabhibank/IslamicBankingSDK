import UIKit

@objc public final class FPIslamicBankingFlowHelper: NSObject {

    @objc(startFlowFrom:)
    public static func startFlow(from viewController: UIViewController) {
        // Use typed creator so SPM does not fall back to plain UIViewController.
        let murabahaVC = IBResource.instantiate(FPMurabahaFinancingVC.self)
        let navigationController = UINavigationController(rootViewController: murabahaVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        viewController.present(navigationController, animated: true)
    }
}
