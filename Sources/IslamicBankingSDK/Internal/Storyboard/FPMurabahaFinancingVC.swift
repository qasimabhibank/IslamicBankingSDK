//
//  FPMurabahaFinancingVC.swift
//  Finca
//

import UIKit

@objc(FPMurabahaFinancingVC) class FPMurabahaFinancingVC: FPIslamicBankingBaseVC {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var navBarStackView: UIStackView!
    @IBOutlet weak var keyFeaturesCardView: UIView!
    @IBOutlet weak var lblKeyFeaturesTitle: UILabel!
    @IBOutlet weak var howItWorksContainerView: UIView!
    @IBOutlet weak var lblHowItWorksTitle: UILabel!
    @IBOutlet weak var howItWorksStepsStackView: UIStackView!
    @IBOutlet weak var howItWorksHeaderView: UIView!
    @IBOutlet weak var imgHowItWorksChevron: UIImageView!

    private var isHowItWorksExpanded = true
    private var howItWorksStepsHeightConstraint: NSLayoutConstraint?
    private let viewModel = FPMurabahaFinancingViewModel()

    private let stepBadgeColor = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupHeroBanner()
        setupKeyFeaturesCard()
        setupHowItWorksSection()
        setupStepRows()
        setupContinueButton()
        setupViewModelBindings()
    }

    @IBAction func btnContinueTapped(_ sender: UIButton) {
        fetchMurabahaApplications()
    }

    @objc private func howItWorksHeaderTapped(_ sender: Any) {
        isHowItWorksExpanded.toggle()
        updateHowItWorksExpandedState(animated: true)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        lblTitle.text = "Murabaha Financing"
        lblTitle.font = UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold)
        lblTitle.textColor = .white

        navBarStackView.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 56
        }
    }

    private static let heroAspectRatio: CGFloat = (266.0 / 320.0) * 0.9

    private func setupHeroBanner() {
        heroImageView.image = IBResource.image("murabaha-hero-banner")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.layer.cornerRadius = 24
        heroImageView.layer.masksToBounds = true
        heroImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        heroImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        applyHeroAspectRatioConstraint()
    }

    private func applyHeroAspectRatioConstraint() {
        let existingAspectConstraints = heroImageView.constraints.filter {
            $0.firstAttribute == .height
                && $0.secondItem as? UIView === heroImageView
                && $0.secondAttribute == .width
        }
        if existingAspectConstraints.isEmpty {
            let aspectConstraint = heroImageView.heightAnchor.constraint(
                equalTo: heroImageView.widthAnchor,
                multiplier: Self.heroAspectRatio
            )
            aspectConstraint.priority = .required
            aspectConstraint.isActive = true
        } else {
            existingAspectConstraints.forEach { $0.priority = .required }
        }
    }

    private func setupKeyFeaturesCard() {
        // Visual styling (icons, fonts, colors, glass card) lives in the storyboard.
        keyFeaturesCardView.layer.masksToBounds = true

        guard let featuresStack = keyFeaturesCardView.subviews.compactMap({ $0 as? UIStackView }).first else { return }
        featuresStack.spacing = 10

        featuresStack.arrangedSubviews.forEach { row in
            guard let rowStack = row as? UIStackView else { return }
            rowStack.spacing = 12
            rowStack.alignment = .center

            // Fallback if a row still has a plain tick imageView instead of the storyboard container.
            if let imageView = rowStack.arrangedSubviews.first as? UIImageView {
                let tickContainer = makeFeatureTickContainer(imageView: imageView)
                rowStack.removeArrangedSubview(imageView)
                imageView.removeFromSuperview()
                rowStack.insertArrangedSubview(tickContainer, at: 0)
            }

            rowStack.arrangedSubviews.compactMap { $0 as? UIStackView }.forEach { textStack in
                textStack.arrangedSubviews.compactMap { $0 as? UILabel }.forEach {
                    $0.numberOfLines = 0
                }
            }
        }
    }

    private func makeFeatureTickContainer(imageView: UIImageView) -> UIView {
        let tickSize: CGFloat = 28
        let iconSize: CGFloat = 14
        let tickBackground = UIColor(red: 22 / 255, green: 163 / 255, blue: 74 / 255, alpha: 0.1)

        let container = UIView()
        container.backgroundColor = tickBackground
        container.layer.cornerRadius = tickSize / 2
        container.translatesAutoresizingMaskIntoConstraints = false

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.deactivate(imageView.constraints)
        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: tickSize),
            container.heightAnchor.constraint(equalToConstant: tickSize),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: iconSize),
            imageView.heightAnchor.constraint(equalToConstant: iconSize)
        ])

        return container
    }

    private func setupHowItWorksSection() {
        // Header/title colors and corner styling come from the storyboard.
        imgHowItWorksChevron.image = IBResource.image("murabaha-chevron-up")
        imgHowItWorksChevron.contentMode = .scaleAspectFit

        howItWorksContainerView.backgroundColor = .clear
        howItWorksContainerView.layer.borderWidth = 0

        howItWorksStepsHeightConstraint = howItWorksStepsStackView.heightAnchor.constraint(equalToConstant: howItWorksStepsStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height)
        howItWorksStepsHeightConstraint?.isActive = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(howItWorksHeaderTapped(_:)))
        howItWorksHeaderView.addGestureRecognizer(tap)
        howItWorksHeaderView.isUserInteractionEnabled = true
    }

    private func updateHowItWorksExpandedState(animated: Bool) {
        let updates = {
            self.howItWorksStepsStackView.isHidden = !self.isHowItWorksExpanded
            self.howItWorksStepsStackView.alpha = self.isHowItWorksExpanded ? 1 : 0
            self.imgHowItWorksChevron.transform = self.isHowItWorksExpanded
                ? .identity
                : CGAffineTransform(rotationAngle: .pi)
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: updates)
        } else {
            updates()
        }
    }

    private func setupStepRows() {
        // Badge size/corners and label colors come from the storyboard.
        howItWorksStepsStackView.arrangedSubviews.forEach { row in
            guard let rowStack = row as? UIStackView else { return }
            rowStack.spacing = 12

            rowStack.arrangedSubviews.forEach { child in
                if child.subviews.contains(where: { ($0 as? UILabel)?.text?.count == 1 }) {
                    child.layer.cornerRadius = 10
                    child.backgroundColor = stepBadgeColor
                    child.clipsToBounds = true
                }

                if let textStack = child as? UIStackView {
                    textStack.spacing = 2
                    textStack.arrangedSubviews.compactMap { $0 as? UILabel }.dropFirst().forEach {
                        $0.numberOfLines = 0
                    }
                }
            }
        }
    }

    private func setupContinueButton() {
        let buttonGreen = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)

        if #available(iOS 15.0, *) {
            if var config = btnContinue.configuration {
                config.title = "View My Proposals"
                config.baseForegroundColor = .white
                config.background.backgroundColor = buttonGreen
                config.background.image = nil
                config.background.cornerRadius = 24
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
                    return outgoing
                }
                btnContinue.configuration = config
            } else {
                btnContinue.setTitle("View My Proposals", for: .normal)
                btnContinue.setTitleColor(.white, for: .normal)
                btnContinue.backgroundColor = buttonGreen
                btnContinue.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
            }
        } else {
            btnContinue.setTitle("View My Proposals", for: .normal)
            btnContinue.setTitleColor(.white, for: .normal)
            btnContinue.backgroundColor = buttonGreen
            btnContinue.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        }

        btnContinue.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = 48 }
        btnContinue.layer.cornerRadius = 24
        btnContinue.clipsToBounds = true
    }
    
    // MARK: - API

    private func setupViewModelBindings() {
        viewModel.applicationsResponse.bind { [weak self] response in
            guard let self, let response else { return }
            //self.printMurabahaApplicationsResponse(response)
            self.openIslamicBankingMyProposalsVC(response)
        }

        viewModel.applicationsError.bind { [weak self] errorMessage in
            guard let self, let errorMessage, !errorMessage.isEmpty else { return }
            IBUI.showAlert(title: "", message: errorMessage)
        }
    }

    private func fetchMurabahaApplications() {
        viewModel.fetchMurabahaApplications()
    }
    
    
    private func openIslamicBankingMyProposalsVC(_ response: FPMurabahaApplicationsResponse) {
        

        if response.data?.isEmpty ?? true {
            IBUI.showAlert(title: "", message: "No applications found")
            return
        }
        openProposalScreen(withIdentifier: "FPIslamicBankingMyProposalsVC", proposals: response.data ?? [])
        
    }

    
    private func printMurabahaApplicationsResponse(_ response: FPMurabahaApplicationsResponse) {
        print("\n========== Murabaha Applications API ==========")
        print("Code: \(response.code ?? -1)")
        print("Message: \(response.msg ?? "")")
        print("RefId: \(response.refId ?? "")")

        let applications = response.data ?? []
        print("Applications Count: \(applications.count)")

        if let encoded = try? JSONEncoder().encode(response),
           let json = String(data: encoded, encoding: .utf8) {
            print("Raw Response JSON:\n\(json)")
        }

        applications.enumerated().forEach { index, application in
            let item = application.toProposalItem()
            print(
                """
                [\(index + 1)] applicationId=\(application.applicationId ?? 0), applicant=\(application.applicantName ?? "-"), purpose=\(application.purpose?.name ?? "-"), documentStatus=\(application.documentStatus?.label ?? "-"), offerToPurchase=\(application.offerToPurchase ?? false), declaration=\(application.declaration ?? false), mappedStatus=\(item.status.badgeTitle), date=\(item.date), amount=\(item.amount)
                """
            )
        }
        print("===============================================\n")
    }
}
