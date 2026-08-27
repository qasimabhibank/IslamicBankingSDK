import UIKit

@objc(FPIslamicBankingBaseVC) class FPIslamicBankingBaseVC: UIViewController {

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
        let viewController: UIViewController
        switch identifier {
        case "FPMurabahaFinancingVC":
            viewController = IBResource.instantiate(FPMurabahaFinancingVC.self)
        case "FPIslamicBankingCNICVC":
            viewController = IBResource.instantiate(FPIslamicBankingCNICVC.self)
        case "FPIslamicBankingMyProposalsVC":
            viewController = IBResource.instantiate(FPIslamicBankingMyProposalsVC.self)
        case "FPIslamicBankingProposalDetailsVC":
            viewController = IBResource.instantiate(FPIslamicBankingProposalDetailsVC.self)
        case "FPIslamicBankingProposalDetailVC":
            viewController = IBResource.instantiate(FPIslamicBankingProposalDetailVC.self)
        case "FPIslamicBankingAllSetPopupVC":
            viewController = IBResource.instantiate(FPIslamicBankingAllSetPopupVC.self)
        default:
            viewController = islamicBankingStoryboard().instantiateViewController(withIdentifier: identifier)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    func pushProposalDetailScreen(withIdentifier identifier: String, proposal: FPMurabahaApplicationModel) {
        if identifier == "FPIslamicBankingProposalDetailsVC" {
            let detailsVC = IBResource.instantiate(FPIslamicBankingProposalDetailsVC.self)
            detailsVC.configure(with: proposal)
            navigationController?.pushViewController(detailsVC, animated: true)
            return
        }

        let completedDetailVC = IBResource.instantiate(FPIslamicBankingProposalDetailVC.self)
        completedDetailVC.configure(with: nil, proposal: proposal)
        navigationController?.pushViewController(completedDetailVC, animated: true)
    }

    func pushCompletedProposalDetailScreen(
        repaymentPlanResponse: FPMurabahaRepaymentPlanResponse?,
        proposal: FPMurabahaApplicationModel?
    ) {
        let viewController = IBResource.instantiate(FPIslamicBankingProposalDetailVC.self)
        viewController.configure(with: repaymentPlanResponse, proposal: proposal)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func openProposalScreen(withIdentifier identifier: String, proposals: [FPMurabahaApplicationModel]) {
        let viewController = IBResource.instantiate(FPIslamicBankingMyProposalsVC.self)
        viewController.proposals = proposals
        navigationController?.pushViewController(viewController, animated: true)
    }

    func openCNICScreen(withIdentifier identifier: String, proposals: [FPMurabahaApplicationModel]) {
        let viewController = IBResource.instantiate(FPIslamicBankingCNICVC.self)
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
        let popup = IBResource.instantiate(FPIslamicBankingAllSetPopupVC.self)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.onBackToHome = onBackToHome
        present(popup, animated: true)
    }
}
