//
//  FPIslamicBankingProposalCardView.swift
//  Finca
//

import UIKit

enum FPIslamicBankingProposalStatus: Int, Codable {

    case inProgress = 1
    case reuploadRequired = 0
    case complete = 2

    var badgeTitle: String {
        switch self {
        case .inProgress: return "In Process"
        case .reuploadRequired: return "Reupload Required"
        case .complete: return "Complete"
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .inProgress: return IBResource.image("inProgress")
        case .reuploadRequired: return IBResource.image("reuploadRequired")
        case .complete: return IBResource.image("proposalComplete")
        }
    }

    var badgeBackgroundColor: UIColor {
        UIColor.white.withAlphaComponent(0.08)
    }

    var badgeTextColor: UIColor {
        switch self {
        case .inProgress: return UIColor(hexString: "#F5A623") ?? .systemOrange
        case .reuploadRequired: return UIColor(hexString: "#EF4444") ?? .systemRed
        case .complete: return UIColor(hexString: "#22C55E") ?? .systemGreen
        }
    }

    var detailsStoryboardIdentifier: String {
        switch self {
        case .complete: return "FPIslamicBankingProposalDetailVC"
        case .inProgress, .reuploadRequired: return "FPIslamicBankingProposalDetailsVC"
        }
    }
}

struct FPIslamicBankingProposalItem {
    let proposalId: String
    let status: FPIslamicBankingProposalStatus
    let title: String
    let date: String
    let amount: String
}

final class FPIslamicBankingProposalCardView: UIView {

    var onTap: (() -> Void)?

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var proposalIdLabel: UILabel!
    @IBOutlet private weak var badgeLabel: UILabel!
    @IBOutlet private weak var badgeView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var amountTitleLabel: UILabel!
    @IBOutlet private weak var amountValueLabel: UILabel!
    @IBOutlet private weak var amountContainerView: UIView!
    @IBOutlet private weak var arrowButton: UIButton!

    private let cardBackgroundColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
    private let amountBackgroundColor = UIColor(red: 0.051, green: 0.098, blue: 0.133, alpha: 1)
    private let secondaryTextColor = UIColor(red: 0.722, green: 0.761, blue: 0.780, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }

    static func loadFromNib() -> FPIslamicBankingProposalCardView {
        guard let view = Bundle.module.loadNibNamed(
            String(describing: FPIslamicBankingProposalCardView.self),
            owner: nil,
            options: nil
        )?.first as? FPIslamicBankingProposalCardView else {
            fatalError("Failed to load FPIslamicBankingProposalCardView.xib")
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func configure(with item: FPMurabahaApplicationModel) {
        let status = item.proposalStatus
        iconView.image = status.iconImage
        proposalIdLabel.text = item.applicationId?.toString ?? "-"
        badgeLabel.text = item.resolvedDocumentStatusLabel
        badgeLabel.textColor = status.badgeTextColor
        badgeView.backgroundColor = status.badgeBackgroundColor
        titleLabel.text = item.resolvedTitle
        dateLabel.text = item.resolvedDate
        amountValueLabel.text = item.resolvedAmount
    }

    @IBAction private func arrowTapped(_ sender: UIButton) {
        onTap?()
    }

    @objc private func handleTap() {
        onTap?()
    }

    private func setupAppearance() {
        backgroundColor = cardBackgroundColor
        layer.cornerRadius = 16
        layer.masksToBounds = true

        proposalIdLabel.textColor = .white
        proposalIdLabel.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)

        badgeLabel.font = UIFont(name: "Inter-SemiBold", size: 10) ?? .systemFont(ofSize: 10, weight: .semibold)
        badgeView.layer.cornerRadius = 6
        badgeView.clipsToBounds = true

        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Inter-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)

        dateLabel.textColor = secondaryTextColor
        dateLabel.font = UIFont(name: "Inter-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)

        amountTitleLabel.textColor = secondaryTextColor
        amountTitleLabel.font = UIFont(name: "Inter-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)

        amountValueLabel.textColor = .white
        amountValueLabel.font = UIFont(name: "Inter-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)

        amountContainerView.backgroundColor = amountBackgroundColor
        amountContainerView.layer.cornerRadius = 12
        amountContainerView.clipsToBounds = true

        iconView.layer.cornerRadius = 12
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFit

        setupArrowButton()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    private func setupArrowButton() {
        arrowButton.clipsToBounds = true
        arrowButton.layer.cornerRadius = 18
        arrowButton.imageView?.contentMode = .scaleAspectFit
        arrowButton.contentHorizontalAlignment = .fill
        arrowButton.contentVerticalAlignment = .fill

        if let circleImage = IBResource.image("rightArrowCircle") {
            arrowButton.backgroundColor = .clear
            arrowButton.setImage(circleImage, for: .normal)
            arrowButton.contentEdgeInsets = .zero
        } else {
            let buttonGreen = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
            arrowButton.backgroundColor = buttonGreen
            arrowButton.tintColor = .white
            let arrowImage = (IBResource.image("rightArrow") ?? UIImage(systemName: "arrow.right"))?
                .withRenderingMode(.alwaysTemplate)
            arrowButton.setImage(arrowImage, for: .normal)
            arrowButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
}

final class FPIslamicBankingProposalCell: UITableViewCell {

    static let reuseIdentifier = "FPIslamicBankingProposalCell"

    private let cardView = FPIslamicBankingProposalCardView.loadFromNib()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.onTap = nil
    }

    func configure(with item: FPMurabahaApplicationModel, onTap: @escaping () -> Void) {
        cardView.configure(with: item)
        cardView.onTap = onTap
    }

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9)
        ])
    }
}
