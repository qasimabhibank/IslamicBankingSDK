import UIKit

@objc
class FPIslamicBankingFlowHelper: NSObject {

    @objc(startFlowFrom:)
    static func startFlow(from viewController: UIViewController) {
        let storyboard = IBResource.storyboard("IslamicBanking")
        let murabahaVC = storyboard.instantiateViewController(withIdentifier: "FPMurabahaFinancingVC")
        let navigationController = UINavigationController(rootViewController: murabahaVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        viewController.present(navigationController, animated: true)
    }
}
