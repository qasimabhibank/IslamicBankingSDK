//
//  FPIslamicBankingSuccessVC.swift
//  Finca
//

import UIKit

@objc
class FPIslamicBankingSuccessVC: FPIslamicBankingBaseVC {

    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var navBarStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgHero: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var infoCardView: UIView!
    @IBOutlet weak var imgWhatNextIcon: UIImageView!
    @IBOutlet weak var lblWhatNextTitle: UILabel!
    @IBOutlet weak var bulletsStackView: UIStackView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnContinueBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!

    private let secondaryTextColor = UIColor(red: 0.722, green: 0.761, blue: 0.780, alpha: 1)
    private let infoBackgroundColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
    private let infoBorderColor = UIColor.white.withAlphaComponent(0.12)
    private let bulletColor = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
    private let accentGreen = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)

    private let bulletTexts = [
        "Bank representative will review your documents within 24-48 hours",
        "You'll receive notification once review is complete",
        "If approved, your repayment schedule will be generated",
        "In case of discrepancy, you'll be notified to reupload documents, or visit the branch"
    ]

    private var repaymentPlanResponse: FPMurabahaRepaymentPlanResponse?
    private var proposal: FPMurabahaApplicationModel?

    func configure(
        repaymentPlanResponse: FPMurabahaRepaymentPlanResponse?,
        proposal: FPMurabahaApplicationModel?
    ) {
        self.repaymentPlanResponse = repaymentPlanResponse
        self.proposal = proposal
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupContent()
        setupInfoCard()
        setupContinueButton()
        populateBullets()
    }

    @IBAction func btnContinueTapped(_ sender: UIButton) {
        guard let repaymentPlanResponse else {
            IBUI.showAlert(title: "", message: "Repayment plan is not available.")
            return
        }

        pushCompletedProposalDetailScreen(
            repaymentPlanResponse: repaymentPlanResponse,
            proposal: proposal
        )
    }

    private func setupNavigationBar() {
        lblNavTitle.text = "Success"
        lblNavTitle.font = UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold)
        lblNavTitle.textColor = .white

        navBarStackView.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 56
        }

        let border = UIView()
        border.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        border.translatesAutoresizingMaskIntoConstraints = false
        navBarStackView.superview?.addSubview(border)
        if let superview = navBarStackView.superview {
            NSLayoutConstraint.activate([
                border.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                border.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                border.bottomAnchor.constraint(equalTo: navBarStackView.bottomAnchor),
                border.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }

    private func setupContent() {
        lblTitle.text = "Documents Submitted!"
        lblTitle.font = UIFont(name: "Inter-Bold", size: 20) ?? .systemFont(ofSize: 20, weight: .bold)
        lblTitle.textColor = .white

        lblSubtitle.text = "Your documents have been submitted successfully and are now under review by the branch"
        lblSubtitle.font = UIFont(name: "Inter-Regular", size: 14) ?? .systemFont(ofSize: 14, weight: .regular)
        lblSubtitle.textColor = secondaryTextColor

        imgHero.contentMode = .scaleAspectFit
        imgHero.image = IBResource.image("documentsSubmittedHero")
    }

    private func setupInfoCard() {
        infoCardView.backgroundColor = infoBackgroundColor
        infoCardView.layer.cornerRadius = 16
        infoCardView.layer.borderWidth = 1
        infoCardView.layer.borderColor = infoBorderColor.cgColor
        infoCardView.clipsToBounds = true

        lblWhatNextTitle.text = "What Happens Next"
        lblWhatNextTitle.font = UIFont(name: "Inter-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)
        lblWhatNextTitle.textColor = .white

        imgWhatNextIcon.contentMode = .scaleAspectFit
        imgWhatNextIcon.image = IBResource.image("successWhatNextIcon")
    }

    private func populateBullets() {
        bulletsStackView.arrangedSubviews.forEach {
            bulletsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for text in bulletTexts {
            bulletsStackView.addArrangedSubview(makeBulletRow(text: text))
        }
    }

    private func makeBulletRow(text: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = bulletColor
        dot.layer.cornerRadius = 2

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont(name: "Inter-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
        label.textColor = secondaryTextColor
        label.numberOfLines = 0

        row.addSubview(dot)
        row.addSubview(label)

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 4),
            dot.heightAnchor.constraint(equalToConstant: 4),
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.topAnchor.constraint(equalTo: row.topAnchor, constant: 6),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }

    private func setupContinueButton() {
        btnContinue.setTitle("Continue", for: .normal)
        btnContinue.setTitleColor(.white, for: .normal)
        btnContinue.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btnContinue.backgroundColor = accentGreen
        btnContinue.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 48
        }
        btnContinue.layer.cornerRadius = 24
        btnContinue.clipsToBounds = true

        if #available(iOS 15.0, *) {
            var config = btnContinue.configuration ?? .plain()
            config.title = "Continue"
            config.baseForegroundColor = .white
            config.background.image = nil
            config.background.backgroundColor = accentGreen
            config.background.cornerRadius = 24
            btnContinue.configuration = config
        }
    }
}
