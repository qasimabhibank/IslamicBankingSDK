//
//  FPOfferToPurchasePopupVC.swift
//  Finca
//
//  Created by FINCA User on 01/07/2026.
//  Copyright © 2026 Finja. All rights reserved.
//

import UIKit

@objc
class FPOfferToPurchasePopupVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var dimmedBackgroundView: UIView!
    @IBOutlet weak var popupCardView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var infoCardView: UIView!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblNameValue: UILabel!
    @IBOutlet weak var lblRelationTitle: UILabel!
    @IBOutlet weak var lblRelationValue: UILabel!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var lblBodyText: UILabel!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var lblGoodsHeader: UILabel!
    @IBOutlet weak var lblCostHeader: UILabel!
    @IBOutlet weak var lblProfitHeader: UILabel!
    @IBOutlet weak var lblTotalHeader: UILabel!
    @IBOutlet weak var lblGoodsValue: UILabel!
    @IBOutlet weak var lblCostValue: UILabel!
    @IBOutlet weak var lblProfitValue: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var colSep1: UIView!
    @IBOutlet weak var colSep2: UIView!
    @IBOutlet weak var colSep3: UIView!
    @IBOutlet weak var rowSeparatorView: UIView!
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var lblConfirmation: UILabel!
    @IBOutlet weak var btnAcceptAndContinue: UIButton!
    @IBOutlet weak var acceptDimOverlayView: UIView!
    @IBOutlet weak var btnGoBack: UIButton!
    @IBOutlet weak var cardMaxHeightConstraint: NSLayoutConstraint!

    // MARK: - Callbacks

    @objc var onAccept: (() -> Void)?
    @objc var onGoBack: (() -> Void)?

    // MARK: - Properties

    var applicationId: Int?
    /// Whether the "Declaration of Purchase" step has already been completed for this application.
    /// Set by the presenting view controller (from the application's `declaration` flag)
    /// before this popup is shown, so the accept submit can echo the correct prior state.
    var isDeclarationAlreadyDone: Bool = false
    private let viewModel = FPMurabahaFinancingViewModel()
    private var isSubmitting = false

    var nameText: String = "-"
    var relationText: String = "-"
    var dateText: String = "-"
    var goodsText: String = "-"
    var costText: String = "-"
    var profitText: String = "-"
    var totalText: String = "-"

    private var isCheckboxSelected = false

    private let cardBackgroundColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
    private let nestedBackgroundColor = UIColor(red: 0.051, green: 0.098, blue: 0.133, alpha: 1)
    private let secondaryTextColor = UIColor(red: 0.722, green: 0.761, blue: 0.780, alpha: 1)
    private let accentGreen = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
    private let goBackBackgroundColor = UIColor(red: 0.039, green: 0.078, blue: 0.110, alpha: 1)

    private let bodyText = """
    I wish to purchase the goods stated below in accordance with the terms agreed in Murabaha Facility Agreement (MFA) and will pay the price as per agreed payment schedule and request to the Institution to sell these goods to me.
    """

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        populateData()
        updateCheckboxAppearance()
        updateAcceptButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewHeight()
    }

    private func updateScrollViewHeight() {
        let maxHeight = max(view.bounds.height - 48, 200)
        cardMaxHeightConstraint.constant = maxHeight

        let targetWidth = scrollView.bounds.width > 0 ? scrollView.bounds.width : (view.bounds.width - 40)
        let contentHeight = contentView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        scrollViewHeightConstraint.constant = min(contentHeight, maxHeight)
    }

    // MARK: - Setup

    private func setupAppearance() {
        dimmedBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        popupCardView.backgroundColor = cardBackgroundColor
        popupCardView.layer.cornerRadius = 16
        popupCardView.clipsToBounds = true

        contentView.backgroundColor = .clear
        scrollView.backgroundColor = .clear

        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: "Inter-SemiBold", size: 18) ?? .systemFont(ofSize: 18, weight: .semibold)

        infoCardView.backgroundColor = nestedBackgroundColor
        infoCardView.layer.cornerRadius = 12
        infoCardView.clipsToBounds = true

        [lblNameTitle, lblRelationTitle, lblDateTitle].forEach {
            $0?.textColor = secondaryTextColor
        }
        [lblNameValue, lblRelationValue, lblDateValue].forEach {
            $0?.textColor = .white
        }

        lblBodyText.textColor = secondaryTextColor

        tableContainerView.backgroundColor = nestedBackgroundColor
        tableContainerView.layer.cornerRadius = 12
        tableContainerView.clipsToBounds = true

        [lblGoodsHeader, lblCostHeader, lblProfitHeader, lblTotalHeader].forEach {
            $0?.textColor = secondaryTextColor
        }
        [lblGoodsValue, lblCostValue, lblProfitValue, lblTotalValue].forEach {
            $0?.textColor = .white
        }

        [colSep1, colSep2, colSep3, rowSeparatorView].forEach {
            $0?.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        }

        btnCheckbox.backgroundColor = .clear
        btnCheckbox.layer.borderWidth = 0
        btnCheckbox.tintColor = accentGreen

        lblConfirmation.textColor = secondaryTextColor
        lblConfirmation.attributedText = confirmationAttributedText()

        setupAcceptButton()
        setupGoBackButton()
    }

    private func setupAcceptButton() {
        btnAcceptAndContinue.setTitle("Accept & Continue", for: .normal)
        btnAcceptAndContinue.setTitleColor(.white, for: .normal)
        btnAcceptAndContinue.setTitleColor(.white, for: .disabled)
        btnAcceptAndContinue.setTitleColor(.white, for: .highlighted)
        btnAcceptAndContinue.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btnAcceptAndContinue.backgroundColor = accentGreen
        btnAcceptAndContinue.layer.cornerRadius = 24
        btnAcceptAndContinue.clipsToBounds = true
        btnAcceptAndContinue.alpha = 1.0

        if #available(iOS 15.0, *) {
            var config = btnAcceptAndContinue.configuration ?? .plain()
            config.title = "Accept & Continue"
            config.baseForegroundColor = .white
            config.background.image = nil
            config.background.backgroundColor = accentGreen
            config.background.cornerRadius = 24
            btnAcceptAndContinue.configuration = config
        }

        acceptDimOverlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        acceptDimOverlayView?.layer.cornerRadius = 24
        acceptDimOverlayView?.clipsToBounds = true
        acceptDimOverlayView?.isUserInteractionEnabled = true
    }

    private func setupGoBackButton() {
        btnGoBack.setTitle("Go Back", for: .normal)
        btnGoBack.setTitleColor(.white, for: .normal)
        btnGoBack.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btnGoBack.backgroundColor = goBackBackgroundColor
        btnGoBack.layer.cornerRadius = 24
        btnGoBack.clipsToBounds = true
        btnGoBack.layer.borderWidth = 1
        btnGoBack.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
    }

    private func populateData() {
        lblNameValue.text = nameText
        lblRelationValue.text = relationText
        lblDateValue.text = dateText
        lblBodyText.text = bodyText
        lblGoodsValue.text = goodsText
        lblCostValue.text = costText
        lblProfitValue.text = profitText
        lblTotalValue.text = totalText
        lblConfirmation.attributedText = confirmationAttributedText()
    }

    private func confirmationAttributedText() -> NSAttributedString {
        let prefix = "I confirm and accept this offer on behalf of "
        let name = nameText
        let suffix = " (\(relationText))."
        let fullText = prefix + name + suffix

        let regularFont = UIFont(name: "Inter-Regular", size: 12) ?? .systemFont(ofSize: 12)
        let boldFont = UIFont(name: "Inter-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)

        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: regularFont,
                .foregroundColor: secondaryTextColor
            ]
        )
        if let range = fullText.range(of: name) {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttributes([.font: boldFont, .foregroundColor: UIColor.white], range: nsRange)
        }
        return attributed
    }

    private func updateCheckboxAppearance() {
        let imageName = isCheckboxSelected ? "checkbox-checked-squre" : "checkbox-unchecked-squre"
        btnCheckbox.setImage(IBResource.image(imageName), for: .normal)
        btnCheckbox.backgroundColor = .clear
        btnCheckbox.layer.borderWidth = 0
    }

    private func updateAcceptButtonState() {
        // Keep button fully opaque with white title; dim via overlay instead.
        btnAcceptAndContinue.alpha = 1.0
        btnAcceptAndContinue.setTitleColor(.white, for: .normal)
        btnAcceptAndContinue.setTitleColor(.white, for: .disabled)
        acceptDimOverlayView?.isHidden = isCheckboxSelected
        acceptDimOverlayView?.isUserInteractionEnabled = true
    }

    // MARK: - IBActions

    @IBAction func btnCheckboxTapped(_ sender: UIButton) {
        isCheckboxSelected.toggle()
        updateCheckboxAppearance()
        updateAcceptButtonState()
    }

    @IBAction func btnAcceptAndContinueTapped(_ sender: UIButton) {
        guard isCheckboxSelected, !isSubmitting else { return }

        guard let applicationId else {
            IBUI.showAlert(title: "", message: "Application ID is missing.")
            dismissPopup(shouldNotifyAccept: false)
            return
        }

        isSubmitting = true
        btnAcceptAndContinue.isUserInteractionEnabled = false

        // We are completing the offer-to-purchase step now, so always pass offerToPurchase = true.
        // declaration reflects whatever prior state was passed in: true only if that step
        // was already completed before this popup was shown.
        viewModel.updateMurabahaDeclaration(
            applicationId: applicationId,
            offerToPurchase: true,
            declaration: isDeclarationAlreadyDone
        ) { [weak self] isSuccessful, message in
            guard let self else { return }

            self.isSubmitting = false
            self.btnAcceptAndContinue.isUserInteractionEnabled = true
            self.updateAcceptButtonState()

            if !isSuccessful, let message, !message.isEmpty {
                IBUI.showAlert(title: "", message: message)
            }

            self.dismissPopup(shouldNotifyAccept: isSuccessful)
        }
    }

    private func dismissPopup(shouldNotifyAccept: Bool) {
        dismiss(animated: true) { [weak self] in
            if shouldNotifyAccept {
                self?.onAccept?()
            }
        }
    }

    @IBAction func btnGoBackTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.onGoBack?()
        }
    }
}
