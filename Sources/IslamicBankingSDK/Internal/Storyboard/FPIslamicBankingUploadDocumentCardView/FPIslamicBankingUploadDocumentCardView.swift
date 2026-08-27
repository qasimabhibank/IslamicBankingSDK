//
//  FPIslamicBankingUploadDocumentCardView.swift
//  Finca
//

import UIKit

enum FPIslamicBankingDocumentStepType {
    case declaration
    case invoice
    case offerToPurchase

    var title: String {
        switch self {
        case .declaration: return "1. Declaration"
        case .invoice: return "2. Invoice"
        case .offerToPurchase: return "3. Offer to Purchase"
        }
    }

    var subtitle: String {
        switch self {
        case .declaration: return "Signed purchase declaration"
        case .invoice: return "jpg or png format"
        case .offerToPurchase: return "Bank offer document"
        }
    }

    var buttonTitle: String {
        switch self {
        case .declaration: return "Sign Declaration"
        case .invoice: return "Upload File"
        case .offerToPurchase: return "Make an Offer"
        }
    }
}

@objc(FPIslamicBankingUploadDocumentCardView) class FPIslamicBankingUploadDocumentCardView: UIView {

    var onActionTapped: (() -> Void)?

    @IBOutlet private weak var cardContainerView: UIView!
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitlePillView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!

    private let primaryTextColor = UIColor(red: 0.161, green: 0.165, blue: 0.176, alpha: 1)
    private let secondaryTextColor = UIColor(red: 0.447, green: 0.447, blue: 0.447, alpha: 1)
    private let borderColor = UIColor(red: 0.769, green: 0.784, blue: 0.831, alpha: 0.55)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }

    static func loadFromNib() -> FPIslamicBankingUploadDocumentCardView {
        guard let view = Bundle.module.loadNibNamed(
            String(describing: FPIslamicBankingUploadDocumentCardView.self),
            owner: nil,
            options: nil
        )?.first as? FPIslamicBankingUploadDocumentCardView else {
            fatalError("Failed to load FPIslamicBankingUploadDocumentCardView.xib")
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func configure(step: FPIslamicBankingDocumentStepType, statusImage: UIImage?) {
        titleLabel.text = step.title
        subtitleLabel.text = step.subtitle
        statusImageView.image = statusImage ?? FPIslamicBankingProposalStatus.inProgress.iconImage
        applyBoldButtonTitle(step.buttonTitle)
    }

    @IBAction private func actionButtonTapped(_ sender: UIButton) {
        onActionTapped?()
    }

    private func setupAppearance() {
        backgroundColor = .clear

        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 8
        cardContainerView.layer.borderWidth = 1
        cardContainerView.layer.borderColor = borderColor.cgColor
        cardContainerView.clipsToBounds = true

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = primaryTextColor

        subtitlePillView.backgroundColor = .white
        subtitlePillView.layer.cornerRadius = 8
        subtitlePillView.clipsToBounds = true

        subtitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        subtitleLabel.textColor = secondaryTextColor

        statusImageView.contentMode = .scaleAspectFit

        actionButton.layer.cornerRadius = 8
        actionButton.clipsToBounds = true
    }

    private func applyBoldButtonTitle(_ title: String) {
        let boldFont = UIFont(name: "Inter-SemiBold", size: 17)
            ?? UIFont.systemFont(ofSize: 17, weight: .bold)

        if #available(iOS 15.0, *) {
            var config = actionButton.configuration ?? UIButton.Configuration.plain()
            config.title = title
            config.baseForegroundColor = .white
            config.background.image = IBResource.image("GradientButton")
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = boldFont
                return outgoing
            }
            actionButton.configuration = config
        } else {
            actionButton.setTitle(title, for: .normal)
            actionButton.titleLabel?.font = boldFont
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.setBackgroundImage(IBResource.image("GradientButton"), for: .normal)
        }
    }
}
