import UIKit

@objc
class FPIslamicBankingBaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.ib_enableDoneAccessoryForTextInputs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func btnBackTapped(_ sender: UIButton) {
        if let navigationController {
            if navigationController.viewControllers.first != self {
                navigationController.popViewController(animated: true)
                return
            }
            if navigationController.presentingViewController != nil {
                navigationController.dismiss(animated: true)
                return
            }
        }
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func islamicBankingStoryboard() -> UIStoryboard {
        IBResource.storyboard("IslamicBanking")
    }

    func pushIslamicBankingScreen(withIdentifier identifier: String) {
        let viewController = islamicBankingStoryboard().instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func pushProposalDetailScreen(withIdentifier identifier: String, proposal: FPMurabahaApplicationModel) {
        let viewController = islamicBankingStoryboard().instantiateViewController(withIdentifier: identifier)

        if let detailsVC = viewController as? FPIslamicBankingProposalDetailsVC {
            detailsVC.configure(with: proposal)
        } else if let completedDetailVC = viewController as? FPIslamicBankingProposalDetailVC {
            completedDetailVC.configure(with: nil, proposal: proposal)
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

    func pushCompletedProposalDetailScreen(
        repaymentPlanResponse: FPMurabahaRepaymentPlanResponse?,
        proposal: FPMurabahaApplicationModel?
    ) {
        let viewController = islamicBankingStoryboard()
            .instantiateViewController(withIdentifier: "FPIslamicBankingProposalDetailVC") as! FPIslamicBankingProposalDetailVC
        viewController.configure(with: repaymentPlanResponse, proposal: proposal)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func openProposalScreen(withIdentifier identifier: String, proposals: [FPMurabahaApplicationModel]) {
        let viewController = islamicBankingStoryboard().instantiateViewController(withIdentifier: identifier) as! FPIslamicBankingMyProposalsVC
        viewController.proposals = proposals
        navigationController?.pushViewController(viewController, animated: true)
    }

    func openCNICScreen(withIdentifier identifier: String, proposals: [FPMurabahaApplicationModel]) {
        let viewController = islamicBankingStoryboard().instantiateViewController(withIdentifier: identifier) as! FPIslamicBankingCNICVC
        navigationController?.pushViewController(viewController, animated: true)
    }

    func pushIslamicBankingSuccessScreen(
        repaymentPlanResponse: FPMurabahaRepaymentPlanResponse? = nil,
        proposal: FPMurabahaApplicationModel? = nil
    ) {
        let viewController = FPIslamicBankingSuccessVC(
            nibName: "FPIslamicBankingSuccessVC",
            bundle: .module
        )
        viewController.configure(
            repaymentPlanResponse: repaymentPlanResponse,
            proposal: proposal
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    func presentAllSetPopup(onBackToHome: (() -> Void)? = nil) {
        let popup = islamicBankingStoryboard()
            .instantiateViewController(withIdentifier: "FPIslamicBankingAllSetPopupVC") as! FPIslamicBankingAllSetPopupVC
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.onBackToHome = onBackToHome
        present(popup, animated: true)
    }
}
