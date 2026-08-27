//
//  FPDeclarationOfPurchasePopupVC.swift
//  Finca
//
//  Created by FINCA User on 01/07/2026.
//  Copyright © 2026 Finja. All rights reserved.
//

import UIKit

@objc(FPDeclarationOfPurchasePopupVC) class FPDeclarationOfPurchasePopupVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var dimmedBackgroundView: UIView!
    @IBOutlet weak var popupCardView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var datePillView: UIView!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var lblDeclaration: UILabel!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var lblNatureOfGoodsHeader: UILabel!
    @IBOutlet weak var lblPurchasePriceHeader: UILabel!
    @IBOutlet weak var lblNatureOfGoodsValue: UILabel!
    @IBOutlet weak var lblPurchasePriceValue: UILabel!
    @IBOutlet weak var lblTotalTitle: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var headerSeparatorView: UIView!
    @IBOutlet weak var dataSeparatorView: UIView!
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var lblConfirmation: UILabel!
    @IBOutlet weak var btnSubmitDeclaration: UIButton!
    @IBOutlet weak var submitDimOverlayView: UIView!
    @IBOutlet weak var btnGoBack: UIButton!

    // MARK: - Callbacks

    @objc var onSubmit: (() -> Void)?
    @objc var onGoBack: (() -> Void)?

    // MARK: - Properties

    var applicationId: Int?
    /// Whether the "Offer to Purchase" step has already been completed for this application.
    /// Set by the presenting view controller (from the application's `offerToPurchase` flag)
    /// before this popup is shown, so the declaration submit can echo the correct prior state.
    var isOfferToPurchaseAlreadyDone: Bool = false
    private let viewModel = FPMurabahaFinancingViewModel()
    private var isSubmitting = false

    var dateText: String = "-"
    var natureOfGoods: String = "-"
    var purchasePrice: String = "-"
    var totalPrice: String = "-"
    var confirmeeName: String = "-"
    var confirmeeRelation: String = "-"

    private var isCheckboxSelected = false

    private let cardBackgroundColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
    private let nestedBackgroundColor = UIColor(red: 0.051, green: 0.098, blue: 0.133, alpha: 1)
    private let secondaryTextColor = UIColor(red: 0.722, green: 0.761, blue: 0.780, alpha: 1)
    private let accentGreen = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
    private let goBackBackgroundColor = UIColor(red: 0.039, green: 0.078, blue: 0.110, alpha: 1)

    private let declarationText = """
    I hereby acknowledge that I have selected/ purchased and negotiated the goods as stated below on behalf of IMD and I further confirm / declare that these selected and negotiated goods (mention below) are of the same nature and specification, as stated in the Order Form and original invoice of purchase is attached. I also acknowledge that I have not used/ consumed the goods purchased on behalf of the bank.
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
        updateSubmitButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        datePillView.layer.cornerRadius = datePillView.bounds.height / 2
    }

    // MARK: - Setup

    private func setupAppearance() {
        dimmedBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        popupCardView.backgroundColor = cardBackgroundColor
        popupCardView.layer.cornerRadius = 16
        popupCardView.clipsToBounds = true

        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: "Inter-SemiBold", size: 18) ?? .systemFont(ofSize: 18, weight: .semibold)

        lblDateTitle.textColor = secondaryTextColor
        lblDateValue.textColor = .white

        datePillView.backgroundColor = nestedBackgroundColor
        datePillView.layer.borderWidth = 1
        datePillView.layer.borderColor = accentGreen.cgColor
        datePillView.clipsToBounds = true

        lblDeclaration.textColor = secondaryTextColor

        tableContainerView.backgroundColor = nestedBackgroundColor
        tableContainerView.layer.cornerRadius = 12
        tableContainerView.clipsToBounds = true

        [lblNatureOfGoodsHeader, lblPurchasePriceHeader].forEach {
            $0?.textColor = secondaryTextColor
        }
        [lblNatureOfGoodsValue, lblPurchasePriceValue, lblTotalTitle, lblTotalValue].forEach {
            $0?.textColor = .white
        }

        headerSeparatorView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        dataSeparatorView.backgroundColor = UIColor.white.withAlphaComponent(0.12)

        btnCheckbox.backgroundColor = .clear
        btnCheckbox.layer.borderWidth = 0
        btnCheckbox.tintColor = accentGreen

        setupSubmitButton()
        setupGoBackButton()
    }

    private func setupSubmitButton() {
        btnSubmitDeclaration.setTitle("Submit Declaration", for: .normal)
        btnSubmitDeclaration.setTitleColor(.white, for: .normal)
        btnSubmitDeclaration.setTitleColor(.white, for: .disabled)
        btnSubmitDeclaration.setTitleColor(.white, for: .highlighted)
        btnSubmitDeclaration.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btnSubmitDeclaration.backgroundColor = accentGreen
        btnSubmitDeclaration.layer.cornerRadius = 24
        btnSubmitDeclaration.clipsToBounds = true
        btnSubmitDeclaration.alpha = 1.0

        if #available(iOS 15.0, *) {
            var config = btnSubmitDeclaration.configuration ?? .plain()
            config.title = "Submit Declaration"
            config.baseForegroundColor = .white
            config.background.image = nil
            config.background.backgroundColor = accentGreen
            config.background.cornerRadius = 24
            btnSubmitDeclaration.configuration = config
        }

        submitDimOverlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        submitDimOverlayView?.layer.cornerRadius = 24
        submitDimOverlayView?.clipsToBounds = true
        submitDimOverlayView?.isUserInteractionEnabled = true
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
        lblDateValue.text = dateText
        lblDeclaration.text = declarationText
        lblNatureOfGoodsValue.text = natureOfGoods
        lblPurchasePriceValue.text = purchasePrice
        lblTotalValue.text = totalPrice
        lblConfirmation.attributedText = confirmationAttributedText()
    }

    private func confirmationAttributedText() -> NSAttributedString {
        let prefix = "I confirm and accept this declaration on behalf of "
        let name = confirmeeName
        let suffix = " (\(confirmeeRelation))."
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

    private func updateSubmitButtonState() {
        // Keep button fully opaque with white title; dim via overlay instead.
        btnSubmitDeclaration.alpha = 1.0
        btnSubmitDeclaration.setTitleColor(.white, for: .normal)
        btnSubmitDeclaration.setTitleColor(.white, for: .disabled)
        submitDimOverlayView?.isHidden = isCheckboxSelected
        submitDimOverlayView?.isUserInteractionEnabled = true
    }

    // MARK: - IBActions

    @IBAction func btnCheckboxTapped(_ sender: UIButton) {
        isCheckboxSelected.toggle()
        updateCheckboxAppearance()
        updateSubmitButtonState()
    }

    @IBAction func btnSubmitDeclarationTapped(_ sender: UIButton) {
        guard isCheckboxSelected, !isSubmitting else { return }

        guard let applicationId else {
            IBUI.showAlert(title: "", message: "Application ID is missing.")
            dismissPopup(shouldNotifySubmit: false)
            return
        }

        isSubmitting = true
        btnSubmitDeclaration.isUserInteractionEnabled = false

        // We are completing the declaration step now, so always pass declaration = true.
        // offerToPurchase reflects whatever prior state was passed in: true only if that
        // step was already completed before this popup was shown.
        viewModel.updateMurabahaDeclaration(
            applicationId: applicationId,
            offerToPurchase: isOfferToPurchaseAlreadyDone,
            declaration: true
        ) { [weak self] isSuccessful, message in
            guard let self else { return }

            self.isSubmitting = false
            self.btnSubmitDeclaration.isUserInteractionEnabled = true
            self.updateSubmitButtonState()

            if !isSuccessful, let message, !message.isEmpty {
                IBUI.showAlert(title: "", message: message)
            }

            self.dismissPopup(shouldNotifySubmit: isSuccessful)
        }
    }

    private func dismissPopup(shouldNotifySubmit: Bool) {
        dismiss(animated: true) { [weak self] in
            if shouldNotifySubmit {
                self?.onSubmit?()
            }
        }
    }

    @IBAction func btnGoBackTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.onGoBack?()
        }
    }
}
